# Janus Gateway

This addon exists to convert RTSP streams into Janus WebRTC streams. Use along with https://github.com/jurriaan/janus-stream-custom-component to create low-latency (<1s) video streams on the frontend.

## Setup
1. Install the janus-strea-custom-component above to get the entities ready for configuration.
2. Create a new secret API key, and store it in secrets.yaml
3. Setup your reverse proxy with a URL or subdomain to be used in the janus URL, pointing to the addon (default is homeassistant:8088).
4. Enable UPnP if you plan on viewing the streams away from home.
5. Configure the addon as documented below
6. Start up the Janus addon
7. Congigure the janus-stream-custom-component as specified in their documentation (update configuration.yaml)
8. Restart Home assistant
9. Add Camera views to front-end. The streams should show up as cameras from the janus-strea-custom-component

## Configuration

### use_cfg [default: false]
Use /share/janus/\*.jcfg files to overwrite janus configs. Useful if you want to use non-RTSP streams and know what you are doing.

### api_secret
Secret API key that the janus-stream-custom-component will need to be able to access this instance. Use `!secret YOUR_SECRET` to pull `YOUR_SECRET` from the secrets.yaml file.

### streams
list of streams with the following params:
#### name
arbitrary name that will be picked up by the janus-stream-custom-component
#### type
janus type of stream. currently only 'rtsp' is realistically supported.
#### url
url of the RTSP stream
#### rtsp_user
user login for the rtsp stream
#### rtsp_pwd
user password for the rtsp stream
### audio [true/false]
does the stream have audio?
### video [true/false]
does the stream hav video?
