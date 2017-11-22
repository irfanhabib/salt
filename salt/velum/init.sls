include:
  - etc-hosts
  - ca-cert
  - cert

{% set names = [salt['pillar.get']('dashboard_external_fqdn', ''),
                salt['pillar.get']('dashboard', '')] %}

{% from '_macros/certs.jinja' import alt_names, certs with context %}
{{ certs("node:" + grains['caasp_fqdn'],
         pillar['ssl']['velum_crt'],
         pillar['ssl']['velum_key'],
         cn = grains['caasp_fqdn'],
         extra_alt_names = alt_names(names)) }}

# TODO: We should not restart the Velum container, but this is required for the new certificates to
#       be loaded. Soon, we should stop serving content directly with Puma and it should be done
#       by web servers instead of application servers (apache, nginx...).
# bsc#1062728: Add onchanges_in cmd: update-velum-hosts. After velum restart /etc/hosts will be recreated,
#       we have to sync this file again with Admin node.
velum_restart:
  cmd.run:
    - name: |-
        velum_id=$(docker ps | grep "velum-dashboard" | awk '{print $1}')
        if [ -n "$velum_id" ]; then
            docker restart $velum_id
        fi
    - onchanges:
      - x509: {{ pillar['ssl']['velum_key'] }}
      - x509: {{ pillar['ssl']['velum_crt'] }}
    - onchanges_in:
      - cmd: update-velum-hosts
