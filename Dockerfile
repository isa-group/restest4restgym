# The image the benchmark runs when it measures RESTest 2.
#
# It is built with the benchmark's own checkout as the build context - that is how the
# benchmark's build step invokes Docker - so every COPY below starts at tools/, and this
# file only means anything once run-evaluation.sh has staged it there.
#
# RESTest is built from source at a commit rather than copied from a machine, so the image
# can say exactly what it contains and anybody can rebuild the same one. The commit comes
# from restgym.lock unless a campaign overrides it.

ARG RESTEST_REPOSITORY=https://github.com/isa-group/RESTest.git
ARG RESTEST_REF=17369e00f244485680f7bd698fff6b60c8684c66

FROM eclipse-temurin:25-jdk AS build
ARG RESTEST_REPOSITORY
ARG RESTEST_REF

RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Fetching one commit rather than cloning a branch: a branch moves, and an image that
# cannot say which revision it holds makes every number it produces unciteable.
RUN git init -q . \
 && git remote add origin "${RESTEST_REPOSITORY}" \
 && git fetch -q --depth 1 origin "${RESTEST_REF}" \
 && git checkout -q FETCH_HEAD

RUN ./mvnw -B -DskipTests package

# What a distribution of RESTest is: the command-line jar and the libraries it runs with.
# The jar keeps its manifest, which is how a run's report says which version produced it.
RUN mkdir -p /dist/lib \
 && cp "$(find restest-cli/target -maxdepth 1 -name 'restest-cli-*.jar' \
          ! -name '*-sources.jar' ! -name '*-javadoc.jar' | head -1)" /dist/restest-cli.jar \
 && cp -a restest-cli/target/lib/. /dist/lib/ \
 && printf '%s at %s\n' "${RESTEST_REPOSITORY}" "${RESTEST_REF}" > /dist/restest-ref.txt \
 && git -C /src log -1 --format='%H %ci %s' >> /dist/restest-ref.txt

# A full JDK rather than a JRE image, and not by accident. RESTest asks for a named random
# number generator, L64X128MixRandom, which lives in the jdk.random module - a module the
# trimmed JRE images leave out. On one of those, every run dies before its first request with
# "no implementation of the random number generator algorithm is available". Java 21 rather
# than the newest, because 21 is the oldest release RESTest supports and a campaign should be
# run on the floor of that range, not the ceiling.
FROM eclipse-temurin:21-jdk

COPY --from=build /dist /tool/dist
COPY ./tools/restest2/restest /tool/restest
COPY ./tools/restest2/entrypoint.sh /tool/entrypoint.sh
RUN chmod +x /tool/restest /tool/entrypoint.sh

# What RESTest is told, as opposed to what it is: a plan and dictionaries per variant, and the
# name of the variant this image was built for. variants/README.md says what a variant is. The
# tool above is cached, so changing the variant rebuilds only these two lines.
COPY ./tools/restest2/variants /tool/variants
COPY ./tools/restest2/variant /tool/variant

WORKDIR /tool
ENTRYPOINT ["/tool/entrypoint.sh"]
