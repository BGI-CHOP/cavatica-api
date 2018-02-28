import sevenbridges as sbg
import os

### Author: Haoxuan Jin (jinh2@email.chop.edu)
# This script is used to modify file metadata of Cavatica by api.
# Usage: python ModifyMetadata.api.py 
###

# Usually these would be set in the shell beforehand
# os.environ['SB_API_ENDPOINT'] = 'https://cavatica-api.sbgenomics.com/v2'
# os.environ['SB_AUTH_TOKEN'] = '<TOKEN_HERE>'

# api = sbg.Api(url='https://cavatica-api.sbgenomics.com/v2', token='<TOKEN_HERE>')
api = sbg.Api(url = os.environ['SB_API_ENDPOINT'], token = os.environ['SB_AUTH_TOKEN'])
my_project = 'cavatica/cbttc-workspace'

# f = open("processData_metadata.clinical.new.csv")
f = open("processData_metadata.clinical.csv")
head = f.readline()
head = head.strip("\n")
features_name = head.split(',')
k = f.readline()
count = 0
while k:
    count += 1
    k = k.strip("\n")
    feature = k.split(',')
    feature[-1] = feature[-1].strip("\n")
    my_file = api.files.get(id=feature[0])
    check = 0
    for i in range(3, len(features_name)):
        # my_file = api.files.query(project=my_project, names = ['00235545-9a85-49df-bf07-94f342824efc.bam'] )
        if feature[i] == '':
            continue
        if (features_name[i] == 'age_at_diagnosis'):
            feature[i] = int(feature[i])
        if (features_name[i] == 'days_to_death'):
            feature[i] = int(feature[i])
        my_file.metadata[features_name[i]] = feature[i]
        check = 1
    if check == 1:
        # try:
        #     my_file.save()
        # except 'sevenbridges.errors.ResourceNotModified',e:
        #     print(e.message)
        #     print(count)
        my_file.save()
    k = f.readline()

