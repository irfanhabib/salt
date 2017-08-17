# invoked by the "update" orchestration right
# before shutting down all the k8s services

include:
 - kubectl-config

# try to save the flannel subnet in the .spec.podCIDR (if not assigned yet)
/tmp/update-pre-shutdown.sh:
  file.managed:
    - source: salt://cni/update-pre-shutdown.sh
    - mode: 0755
  cmd.run:
    - name: /tmp/update-pre-shutdown.sh {{ grains['caasp_fqdn'] }} {{ grains['ip4_interfaces']['eth0'][0] }} 
    - stateful: True
    - env:
      - KUBECONFIG: {{ pillar['paths']['kubeconfig'] }}
    - require:
      - {{ pillar['paths']['kubeconfig'] }}
