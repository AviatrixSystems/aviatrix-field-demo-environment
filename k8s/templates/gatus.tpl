ui:
  header: "Aviatrix"
  logo: "https://aviatrix.com/wp-content/uploads/2023/03/1-1024x1024.png"
  link: "https://www.aviatrix.com"
  title: "Aviatrix"
web:
  port: 8080
endpoints:
%{ for s in egress ~}
    - name: ${s}
      url: "https://${s}"
      client:
        insecure: false
        ignore-redirect: false
        timeout: 2s
      interval: 15s
      group: "${name} [egress]"
      conditions:
      - "[STATUS] == 200"
%{ endfor ~}
%{ for s in services ~}
    - name: ${s}:443
      url: "tcp://${s}.demo.aviatrixtest.com:443"
      client:
        insecure: false
        ignore-redirect: false
        timeout: 2s
      interval: 15s
      group: "${name}"
      conditions:
      - "[CONNECTED] == true"
%{ endfor ~}
%{ for s in databases ~}
    - name: ${s}:3306
      url: "tcp://${s}.demo.aviatrixtest.com:3306"
      client:
        insecure: false
        ignore-redirect: false
        timeout: 2s
      interval: 15s
      group: "${name}"
      conditions:
      - "[CONNECTED] == true"
%{ endfor ~}
