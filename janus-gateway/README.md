# Janus Gateway

This addon exists to convert RTSP streams into Janus WebRTC streams. Use along with https://github.com/jurriaan/janus-stream-custom-component to create low-latency (<1s) video streams on the frontend.

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
