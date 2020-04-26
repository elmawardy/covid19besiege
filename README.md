# covid19besiege

![version](https://img.shields.io/static/v1?label=version&message=3.4.0&color=green)

[Database Schema](./doc/schema)

[Mobile Application (Flutter)](./MobileApp)

![MobileApp gif](https://i.imgur.com/whmPh9u.gif)


## Backend quick installation (Docker)
- install docker and [docker-compose](https://docs.docker.com/compose/install/) if they are not installed
- cd to docker directory inside the project
- run **#docker-compose up**
  - this should download and run the project public docker containers on your local pc.
  - this exposes port 8000:8000 by default so make sure port 8000 is free or change the port before ":" sign in docker-compose.yml
  - makre sure your host ip in globals.dart matches your pc ip.

## TODO

- &#10004; detect nearby devices & save in db
- &#10004; get contact history
- &#10004; Stats/Awareness page
- &#10004; Stat other countries
- &#10004; Stat Refresh button
- &#9744; Get specific states/districts statistics
- &#10004; Read/Write person state in redis cache
- &#9744; Stats gathered from native
  dataset
