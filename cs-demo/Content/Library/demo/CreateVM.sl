namespace: demo
flow:
  name: CreateVM
  inputs:
    - host: 10.0.46.10
    - username: "Capa1\\1273-Capa1user"
    - password: Automation123
    - datacenter: Capa1 Datacenter
    - image: Ubuntu
    - folder: JJG
    - prefix_list: '1-,2-,3-'
  workflow:
    - uuid:
        do:
          io.cloudslang.demo.uuid: []
        publish:
          - uuid: '${"jjg-"+uuid}'
        navigate:
          - SUCCESS: substring
    - substring:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${uuid}'
            - end_index: '12'
        publish:
          - id: '${new_string}'
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: FAILURE
    - clone_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.vm.clone_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_source_identifier: name
              - vm_source: '${image}'
              - datacenter: '${datacenter}'
              - vm_name: '${prefix+id}'
              - vm_folder: '${folder}'
              - mark_as_template: 'false'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: FAILURE
    - power_on_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.power_on_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: wait_for_vm_info
          - FAILURE: FAILURE
    - wait_for_vm_info:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.util.wait_for_vm_info:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - datacenter: '${datacenter}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        publish:
          - ip_list: '${str([str(x["ip"]) for x in branches_context])}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
  outputs:
    - ip_list: '${ip_list}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      uuid:
        x: 100
        y: 250
      substring:
        x: 400
        y: 250
        navigate:
          a69f9aff-a2bc-aac8-2e38-074ce5a836e3:
            targetId: 3d5eb550-c7a1-3880-76d4-4bb8d9f65202
            port: FAILURE
      clone_vm:
        x: 699
        y: 247
        navigate:
          b5763e4a-6d1a-a61e-fc32-c31e269d44e4:
            targetId: 3d5eb550-c7a1-3880-76d4-4bb8d9f65202
            port: FAILURE
      power_on_vm:
        x: 1000
        y: 250
        navigate:
          0aae475d-d440-59a8-b405-5cc5f45233c5:
            targetId: 3d5eb550-c7a1-3880-76d4-4bb8d9f65202
            port: FAILURE
      wait_for_vm_info:
        x: 1300
        y: 250
        navigate:
          e3f2a840-5ffe-d7e3-b8b3-4b8ce7926be5:
            targetId: 2d59fb8c-be70-d83c-4df9-f678084c68d5
            port: SUCCESS
          cfe3d81b-d290-780c-a107-79c61c320b5e:
            targetId: 3d5eb550-c7a1-3880-76d4-4bb8d9f65202
            port: FAILURE
    results:
      SUCCESS:
        2d59fb8c-be70-d83c-4df9-f678084c68d5:
          x: 1600
          y: 250
      FAILURE:
        3d5eb550-c7a1-3880-76d4-4bb8d9f65202:
          x: 720
          y: 1
