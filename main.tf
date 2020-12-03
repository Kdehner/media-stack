provider "docker" {
  alias = "rpi"
  host  = "ssh://rpi"
}

provider "docker" {
  alias = "media"
  host  = "ssh://media"
}

resource "docker_image" "sabnzbd" {
  name         = "ghcr.io/linuxserver/sabnzbd"
  keep_locally = "true"
}
resource "docker_image" "sonarr" {
  name         = "ghcr.io/linuxserver/sonarr"
  keep_locally = "true"
}
resource "docker_image" "plex" {
  name         = "ghcr.io/linuxserver/plex"
  keep_locally = "true"
}
resource "docker_image" "radarr" {
  name         = "ghcr.io/linuxserver/radarr"
  keep_locally = "true"
}
resource "docker_image" "radarr_sync" {
  name         = "kdehner/radarrsync"
  keep_locally = "true"
}
resource "docker_image" "lidarr" {
  name         = "ghcr.io/linuxserver/lidarr"
  keep_locally = "true"
}
resource "docker_image" "nginx" {
  name         = "ghcr.io/linuxserver/nginx"
  keep_locally = "true"
}

resource "docker_network" "media" {
  name = "media"
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "nginx"
  env   = ["PUID=1000", "PGID=1001", "TZ=America/Denver"]
  networks_advanced {
    name = docker_network.media.name
  }
  volumes {
    container_path = "/config"
    volume_name    = docker_volume.nginx.name
  }
  ports {
    internal = 80
    external = 80
  }
  restart = "unless-stopped"
}

resource "docker_container" "sabnzbd" {
  provider = docker.media
  image    = docker_image.sabnzbd.latest
  name     = "sabnzbd"
  env      = ["PUID=1000", "PGID=1001", "TZ=America/Denver"]
  networks_advanced {
    name = docker_network.media.name
  }
  volumes {
    container_path = "/downloads"
    volume_name    = docker_volume.downloads.name
  }
  volumes {
    container_path = "/config"
    volume_name    = docker_volume.sabnzbd.name
  }
  ports {
    internal = 8080
    external = 9001
  }
  restart = "unless-stopped"
}

resource "docker_container" "sonarr" {
  provider = docker.media
  image    = docker_image.sonarr.latest
  name     = "sonarr"
  env      = ["PUID=1000", "PGID=1001", "TZ=America/Denver"]
  networks_advanced {
    name = docker_network.media.name
  }
  volumes {
    container_path = "/downloads"
    volume_name    = docker_volume.downloads.name
  }
  volumes {
    container_path = "/tv"
    volume_name    = docker_volume.tvshows.name
  }
  volumes {
    container_path = "/config"
    volume_name    = docker_volume.sonarr.name
  }
  ports {
    internal = 8989
    external = 9002
  }
  restart = "unless-stopped"
}

resource "docker_container" "radarr" {
  provider = docker.media
  image    = docker_image.radarr.latest
  name     = "radarr"
  env      = ["PUID=1000", "PGID=1001", "TZ=America/Denver"]
  networks_advanced {
    name = docker_network.media.name
  }
  volumes {
    container_path = "/downloads"
    volume_name    = docker_volume.downloads.name
  }
  volumes {
    container_path = "/movies"
    volume_name    = docker_volume.movies.name
  }
  volumes {
    container_path = "/config"
    volume_name    = docker_volume.radarr.name
  }
  ports {
    internal = 7878
    external = 9003
  }
  restart = "unless-stopped"
}

resource "docker_container" "lidarr" {
  provider = docker.media
  image    = docker_image.lidarr.latest
  name     = "lidarr"
  env      = ["PUID=1000", "PGID=1001", "TZ=America/Denver"]
  networks_advanced {
    name = docker_network.media.name
  }
  volumes {
    container_path = "/downloads"
    volume_name    = docker_volume.downloads.name
  }
  volumes {
    container_path = "/music"
    volume_name    = docker_volume.music.name
  }
  volumes {
    container_path = "/config"
    volume_name    = docker_volume.lidarr.name
  }
  ports {
    internal = 8686
    external = 9005
  }
  restart = "unless-stopped"
}

resource "docker_container" "radarr4k" {
  provider = docker.media
  image    = docker_image.radarr.latest
  name     = "radarr4k"
  env      = ["PUID=1000", "PGID=1001", "TZ=America/Denver"]
  networks_advanced {
    name = docker_network.media.name
  }
  volumes {
    container_path = "/downloads"
    volume_name    = docker_volume.downloads.name
  }
  volumes {
    container_path = "/movies"
    volume_name    = docker_volume.movies4k.name
  }
  volumes {
    container_path = "/config"
    volume_name    = docker_volume.radarr4k.name
  }
  ports {
    internal = 7878
    external = 9004
  }
  restart = "unless-stopped"
}

resource "docker_container" "plex" {
  provider     = docker.rpi
  image        = docker_image.plex.latest
  name         = "plex"
  env          = ["PUID=1000", "PGID=1001", "TZ=America/Denver", "VERSION=docker"]
  network_mode = "host"
  volumes {
    container_path = "/movies"
    volume_name    = docker_volume.movies.name
  }
  volumes {
    container_path = "/tv"
    volume_name    = docker_volume.tvshows.name
  }
  volumes {
    container_path = "/movies4k"
    volume_name    = docker_volume.movies4k.name
  }
  volumes {
    container_path = "/music"
    volume_name    = docker_volume.music.name
  }
  volumes {
    container_path = "/config"
    volume_name    = docker_volume.plex.name
  }
  restart = "unless-stopped"
}

resource "docker_container" "radarr_sync" {
  provider = docker.media
  image    = docker_image.radarr_sync.latest
  name     = "radarr_sync"
  env = ["SOURCE_RADARR_URL=http://radarr:7878", "SOURCE_RADARR_KEY=cfc79343909349d4a7bd72f934b5e7a5",
    "SOURCE_RADARR_PATH=/movies", "TARGET_RADARR_PATH=/movies",
    "TARGET_RADARR_URL=http://radarr4k:7878", "TARGET_RADARR_KEY=86d72158f1904420be828a1c64460e64",
  "SOURCE_RADARR_PROFILE_NUM=8", "TARGET_RADARR_PROFILE_NUM=5", "DELAY=1m"]
  networks_advanced {
    name = docker_network.media.name
  }
  restart = "unless-stopped"
}

resource "docker_volume" "downloads" {
  name   = "downloads"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "${var.downloads}/downloads"
    o      = "bind"
  }
}

resource "docker_volume" "tvshows" {
  name   = "tvshows"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "${var.media}/tvshows"
    o      = "bind"
  }
}

resource "docker_volume" "movies" {
  name   = "movies"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "${var.media}/movies"
    o      = "bind"
  }
}

resource "docker_volume" "movies4k" {
  name   = "movies4k"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "${var.media}/movies4k"
    o      = "bind"
  }
}

resource "docker_volume" "music" {
  name   = "music"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "${var.media}/music"
    o      = "bind"
  }
}

resource "docker_volume" "sabnzbd" {
  name   = "sabnzbd_config"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "${var.config}/sabnzbd"
    o      = "bind"
  }
}

resource "docker_volume" "plex" {
  name   = "plex_config"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "/mnt/raid-alpha/config/plex"
    o      = "bind"
  }
}

resource "docker_volume" "sonarr" {
  name   = "sonarr_config"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "${var.config}/sonarr"
    o      = "bind"
  }
}

resource "docker_volume" "radarr" {
  name   = "radarr_config"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "${var.config}/radarr"
    o      = "bind"
  }
}

resource "docker_volume" "radarr4k" {
  name   = "radarr4k_config"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "${var.config}/radarr4k"
    o      = "bind"
  }
}

resource "docker_volume" "lidarr" {
  name   = "lidarr_config"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "${var.config}/lidarr"
    o      = "bind"
  }
}

resource "docker_volume" "nginx" {
  name   = "nginx_config"
  driver = "local"
  driver_opts = {
    type   = "none"
    device = "${var.config}/nginx"
    o      = "bind"
  }
}
