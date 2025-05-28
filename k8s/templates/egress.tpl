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
      interval: 5s
      group: "${name}-egress"
      conditions:
      - "[STATUS] == 200"
%{ endfor ~}
