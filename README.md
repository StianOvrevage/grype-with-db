# grype-with-db

DockerHub: [stianovrevage/grype-with-db](hub.docker.com/r/stianovrevage/grype-with-db)

Regular (Monday, Wednesday, Friday, Sunday) builds of `grype` docker image with built-in database. [Grype](https://github.com/anchore/grype) is "A vulnerability scanner for container images and filesystems."

## Background

By default `grype` will on start-up download a set of vulnerability databases (190MB of network traffic as of 2024-10-09) and populate a SQLite database (1400MB on disk as of 2024-10-09). 

If the vulnerability database is newer than 5 days `grype` considers it usable. Hence I think it makes sense to be able to reduce network traffic (and cost) and also reduce load on the upstream vulnerability database sources by providing regular builds of `grype` with bundled databases that can be cached and re-used.

There are also questions about providing this for use in air-gapped environments; https://github.com/anchore/grype/issues/1652 . However it has been decided against providing it upstream partly due to it being simple to implement by those who need it.

The simplest is of course to have someone else figure it out, which is what I have done here :)

## Usage

Replace `anchore/grype:latest` with `stianovrevage/grype-with-db:latest`:

    docker run --rm stianovrevage/grype-with-db alpine:latest

## Vulnerability database compression

To save on both disk space and network transfer the image is built with a compressed database which is then uncompressed on container startup.

## Performance and benefits

By default Docker Hub compresses container images so the uncompressed-database image with a size on disk of 1.5GB actually only consumes 205MB on Docker Hub and likewise for pulling it.

This image reduces the size to 155MB for a slight saving on pull time and network transfer.

The main benefit is that the size on disk is reduced from 1.5GB to 210MB. This reduction also carries over if transfering the image (for example from caching registries) that do not do automatic compression.

Runtimes are slightly longer due to uncompressing the database, but that is made up for by the smaller size.

Numbers for the standard `grype` image, as well as with database both compressed and uncompressed. Two runs, the first one includes pulling the image from Docker Hub while the second executes the already downloaded image:

    # First run (incl pull): 14.7s   Second run: 12.2s
    time docker run --rm -it anchore/grype:latest alpine:latest
    
    # First run (incl pull): 16.1s   Second run: 2.6s
    time docker run --rm -it stianovrevage/grype-with-db:uncompressed alpine:latest

    # First run (incl pull): 12.2s   Second run: 3.5s
    time docker run --rm -it stianovrevage/grype-with-db alpine:latest
