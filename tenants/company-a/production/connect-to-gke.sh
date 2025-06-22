#!/bin/bash

# Script to connect to GKE cluster and verify storage configuration
set -e

echo "🔧 Connecting to GKE cluster..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GKE connection details from Terraform output
PROJECT_ID="multi-tenant-dataloop"
CLUSTER_NAME="company-a-production-cluster"
REGION="us-west1"

echo -e "${BLUE}Connecting to GKE cluster: ${CLUSTER_NAME} in ${REGION}${NC}"

# Connect to GKE cluster
if command -v gcloud &> /dev/null; then
    echo "✅ gcloud CLI found, connecting to cluster..."
    gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT_ID
else
    echo -e "${YELLOW}⚠️  gcloud CLI not found. Please install it or use the manual steps below:${NC}"
    echo ""
    echo "Manual connection steps:"
    echo "1. Install gcloud CLI: https://cloud.google.com/sdk/docs/install"
    echo "2. Run: gcloud auth login"
    echo "3. Run: gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT_ID"
    echo ""
    exit 1
fi

echo ""
echo "🔍 Verifying cluster connection..."
kubectl cluster-info

echo ""
echo "📦 Checking available storage classes..."
kubectl get storageclass

echo ""
echo "🔍 Checking PVC status in monitoring namespace..."
kubectl get pvc -n monitoring || echo "No PVCs found in monitoring namespace (this is normal if just deployed)"

echo ""
echo "🏃 Checking Prometheus and Grafana pods..."
kubectl get pods -n monitoring

echo ""
echo "📊 Checking Prometheus StatefulSet..."
kubectl get statefulset -n monitoring

echo ""
echo "🎯 Checking services in monitoring namespace..."
kubectl get svc -n monitoring

echo ""
echo "📋 Storage verification complete!"
echo -e "${GREEN}✅ Connected to GKE cluster successfully${NC}"
echo ""
echo "Next steps:"
echo "1. Check if PVCs are bound correctly"
echo "2. Verify Prometheus and Grafana pods are running"
echo "3. Test access to Grafana LoadBalancer IP"
