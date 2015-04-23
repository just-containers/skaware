# skaware [![Build Status](https://travis-ci.org/just-containers/skaware.svg)](https://travis-ci.org/just-containers/skaware)

```
mkdir dist
chmod o+rw dist
docker build .                                            | \
tail -n 1 | awk '{ print $3; }'                           | \
xargs docker run --rm -v `pwd`/dist:/skarnet-builder/dist
```
