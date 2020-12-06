provider "docker" {
  alias = "rpi"
  host  = "ssh://rpi"
}

provider "docker" {
  alias = "media"
  host  = "ssh://media"
}

resource "docker_image" "sabnzbd" {
  provider     = docker.media
  name         = "ghcr.io/linuxserver/sabnzbd"
  keep_locally = "true"
}
resource "docker_image" "sonarr" {
  provider     = docker.media
  name         = "ghcr.io/linuxserver/sonarr"
  keep_locally = "true"
}
resource "docker_image" "plex" {
  provider     = docker.rpi
  name         = "ghcr.io/linuxserver/plex"
  keep_locally = "true"
}
resource "docker_image" "radarr" {
  provider     = docker.media
  name         = "ghcr.io/linuxserver/radarr"
  keep_locally = "true"
}
resource "docker_image" "radarr_sync" {
  provider     = docker.media
  name         = "funkypenguin/radarrsync"
  keep_locally = "true"
}
resource "docker_image" "lidarr" {
  provider     = docker.media
  name         = "ghcr.io/linuxserver/lidarr"
  keep_locally = "true"
}
resource "docker_image" "nginx" {
  provider     = docker.media
  name         = "ghcr.io/linuxserver/nginx"
  keep_locally = "true"
}
resource "docker_image" "telegraf" {
  provider     = docker.media
  name         = "telegraf"
  keep_locally = "true"
}

resource "docker_network" "media" {
  provider = docker.media
  name     = "media"
}

resource "docker_container" "nginx" {
  provider = docker.media
  image    = docker_image.nginx.latest
  name     = "nginx"
  env      = ["PUID=1000", "PGID=1000", "TZ=America/Denver"]
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
  env      = ["PUID=1000", "PGID=1000", "TZ=America/Denver"]
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
    external = 8001
  }
  restart = "unless-stopped"
}

resource "docker_container" "sonarr" {
  provider = docker.media
  image    = docker_image.sonarr.latest
  name     = "sonarr"
  env      = ["PUID=1000", "PGID=1000", "TZ=America/Denver"]
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
    external = 8002
  }
  restart = "unless-stopped"
}

resource "docker_container" "radarr" {
  provider = docker.media
  image    = docker_image.radarr.latest
  name     = "radarr"
  env      = ["PUID=1000", "PGID=1000", "TZ=America/Denver"]
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
    external = 8003
  }
  restart = "unless-stopped"
}

resource "docker_container" "lidarr" {
  provider = docker.media
  image    = docker_image.lidarr.latest
  name     = "lidarr"
  env      = ["PUID=1000", "PGID=1000", "TZ=America/Denver"]
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
    external = 8005
  }
  restart = "unless-stopped"
}

resource "docker_container" "radarr4k" {
  provider = docker.media
  image    = docker_image.radarr.latest
  name     = "radarr4k"
  env      = ["PUID=1000", "PGID=1000", "TZ=America/Denver"]
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
    external = 8004
  }
  restart = "unless-stopped"
}

resource "docker_container" "plex" {
  provider     = docker.rpi
  image        = docker_image.plex.latest
  name         = "plex"
  env          = ["PUID=1000", "PGID=1000", "TZ=America/Denver", "VERSION=docker"]
  network_mode = "host"
  volumes {
    container_path = "/media"
    volume_name    = docker_volume.media.name
    read_only      = "true"
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
  env = ["SOURCE_RADARR_URL=http://radarr:7878", "SOURCE_RADARR_KEY=7b5cb38d2dcc4664ac885756430d3a1e",
    "SOURCE_RADARR_PATH=/movies", "TARGET_RADARR_PATH=/movies",
    "TARGET_RADARR_URL=http://radarr4k:7878", "TARGET_RADARR_KEY=3227a58b17a3472e9f0c9afa60835fcb",
  "SOURCE_RADARR_PROFILE_NUM=5", "TARGET_RADARR_PROFILE_NUM=5", "DELAY=1m"]
  networks_advanced {
    name = docker_network.media.name
  }
  restart = "unless-stopped"
}

resource "docker_container" "telegraf" {
  provider = docker.media
  image    = docker_image.telegraf.latest
  name     = "telegraf"
  hostname = "kevbot-media"
  env = ["PUID=1000", "PGID=1001", "TZ=America/Denver",
    "HOST_ETC=/hostfs/etc",
    "HOST_PROC=/hostfs/proc",
    "HOST_SYS=/hostfs/sys",
    "HOST_VAR=/hostfs/var",
    "HOST_RUN=/hostfs/run",
  "HOST_MOUNT_PREFIX=/hostfs"]
  volumes {
    container_path = "/etc/telegraf/telegraf.conf"
    read_only      = "true"
    host_path      = "/mnt/nas/config/telegraf/telegraf.conf"
  }
  volumes {
    container_path = "/hostfs"
    read_only      = "true"
    host_path      = "/"
  }
  restart = "unless-stopped"
}

resource "docker_volume" "downloads" {
  provider = docker.media
  name     = "downloads"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = var.downloads
    o      = "bind"
  }
}

resource "docker_volume" "tvshows" {
  provider = docker.media
  name     = "tvshows"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "${var.media}/tvshows"
    o      = "bind"
  }
}

resource "docker_volume" "movies" {
  provider = docker.media
  name     = "movies"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "${var.media}/movies"
    o      = "bind"
  }
}

resource "docker_volume" "movies4k" {
  provider = docker.media
  name     = "movies4k"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "${var.media}/movies4k"
    o      = "bind"
  }
}

resource "docker_volume" "music" {
  provider = docker.media
  name     = "music"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "${var.media}/music"
    o      = "bind"
  }
}

resource "docker_volume" "sabnzbd" {
  provider = docker.media
  name     = "sabnzbd_config"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "${var.config}/sabnzbd"
    o      = "bind"
  }
}

resource "docker_volume" "plex" {
  provider = docker.rpi
  name     = "plex_config"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "/mnt/raid-alpha/config/plex"
    o      = "bind"
  }
}

resource "docker_volume" "media" {
  provider = docker.rpi
  name     = "media"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "/mnt/raid-alpha/media"
    o      = "bind"
  }
}

resource "docker_volume" "sonarr" {
  provider = docker.media
  name     = "sonarr_config"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "${var.config}/sonarr"
    o      = "bind"
  }
}

resource "docker_volume" "radarr" {
  provider = docker.media
  name     = "radarr_config"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "${var.config}/radarr"
    o      = "bind"
  }
}

resource "docker_volume" "radarr4k" {
  provider = docker.media
  name     = "radarr4k_config"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "${var.config}/radarr4k"
    o      = "bind"
  }
}

resource "docker_volume" "lidarr" {
  provider = docker.media
  name     = "lidarr_config"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "${var.config}/lidarr"
    o      = "bind"
  }
}

resource "docker_volume" "nginx" {
  provider = docker.media
  name     = "nginx_config"
  driver   = "local"
  driver_opts = {
    type   = "none"
    device = "/mnt/nas/config/nginx"
    o      = "bind"
  }
}
