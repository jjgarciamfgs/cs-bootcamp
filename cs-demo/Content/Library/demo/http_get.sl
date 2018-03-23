namespace: io.cloudslang.demo

operation:
    name: http_get

    inputs:
      - url
      - user
      - password

    python_action:
        script: |
          import requests
          r = request.get(url, auth=(user, password))
          status_code = r.status_code
          json = r.json()
          text = r.text
          headers = r.headers

    outputs:
      - status_code: ${status_code}
      - json: ${json}
      - text = ${text}
      - headers = ${headers}


    results:
      - SUCCESS