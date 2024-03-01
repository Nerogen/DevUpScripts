import azure.functions as func
import logging
from azure.identity import DefaultAzureCredential, ManagedIdentityCredential
from azure.mgmt.compute import ComputeManagementClient

app = func.FunctionApp()


@app.function_name(name="mytimer")
@app.schedule(schedule="0 */10 * * * *",
              arg_name="mytimer",

              )
def test_function(mytimer: func.TimerRequest) -> None:
    subscription_id = "995d5ec1-0351-456b-a35f-7ef5e9c26db0"
    resource_group_name = "group1-koniukh"

    credential = DefaultAzureCredential()
    client = ComputeManagementClient(
        credential=credential,
        subscription_id=subscription_id
    )

    vm = client.virtual_machines.list(resource_group_name)
    for vmid in vm:
        if vmid.tags['script']:
            if vmid.provisioning_state == 'Succeeded' and client.virtual_machines.get(resource_group_name, vmid.name,
                                                                                      expand='instanceView').instance_view.statuses[
                1].display_status == 'VM running':
                client.virtual_machines.begin_deallocate(resource_group_name, vmid.name)
            elif vmid.provisioning_state == 'Succeeded' and client.virtual_machines.get(resource_group_name, vmid.name,
                                                                                        expand='instanceView').instance_view.statuses[
                1].display_status == 'VM deallocated':
                client.virtual_machines.begin_start(resource_group_name, vmid.name)

            else:
                print(f"VM {vmid.name} is in an unexpected state.")
                print(client.virtual_machines.get(resource_group_name, vmid.name,
                                                  expand='instanceView').instance_view.statuses[1].display_status)
