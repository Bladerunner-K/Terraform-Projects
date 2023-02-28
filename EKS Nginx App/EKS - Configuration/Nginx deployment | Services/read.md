firstly we will update the kubernetes configmap with - 
aws eks --region eu-west-2 update-kubeconfig --name eks 

then we will go ahead and create the deployment and service using the following kubectl command 

kubectl apply -f (filepath on our local host)
