FROM centos:7
COPY ./main /
COPY ./static /static
CMD ["/main"]
EXPOSE 8000
