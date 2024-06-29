#!/bin/bash
# Defines default namespace (modify as needed)
namespace="default"

# Help message
help_message="Usage: $(basename "$0") [OPTIONS] [NAMESPACE]\n\nSelects a pod from a list of running pods in the specified namespace (or default namespace if none provided).\n\n  -h      Display this help message.\n  -n      Specify the namespace to list pods from.\n"

# Process arguments using getopts
while getopts "hn:" opt; do
  case "$opt" in
    h)
      echo -e "$help_message"
      exit 0
      ;;
    n)
      namespace="$OPTARG"
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Shift arguments to remove processed options
shift $((OPTIND-1))

# Displays the current namespace
echo -e "\n-----Using namespace: $namespace"

# Check if kubectl is available
if ! command -v kubectl >/dev/null 2>&1; then
  echo "Error: kubectl command not found. Please install kubectl."
  exit 1
fi

# Get list of pods in the specified namespace
pods=$(kubectl get pods --namespace "$namespace" -o custom-columns="NAME:.metadata.name,STATUS:.status.phase" --no-headers)

# Check if there are any pods running
if [[ -z "$pods" ]]; then
  echo "No running pods found in namespace: $namespace"
  exit 1
fi

# Extract pod names and statuses
while read -r pod_name pod_status; do
  pod_names+=("$pod_name")
  pod_statuses+=("$pod_status")
done <<< "$pods"

# Ensure pod_names and pod_statuses have the same number of elements
if [[ "${#pod_names[@]}" -ne "${#pod_statuses[@]}" ]]; then
  echo "Error: Unexpected data format from kubectl. Exiting."
  exit 1
fi

# Function to display pod details
display_pod_details() {
  local pod_name="$1"
  echo "Details of pod: $pod_name"
  source check_pod.sh  "$pod_name" "$namespace"
}

# Prompt for selection using select
PS3="Select a pod (Press Enter to select, or type 'quit'): "
select pod in "${pod_names[@]}"; do
  # Check if a valid option is selected
  if [[ "$REPLY" -gt 0 && "$REPLY" -le "${#pod_names[@]}" ]]; then
    selected_index=$((REPLY - 1))

    # Display details of the selected pod using function
    echo "Displaying pod information for: ${pod_names[$selected_index]} (namespace: $namespace)"
    display_pod_details "${pod_names[$selected_index]}"

    # Exit the loop after selection is made
    break
  elif [[ "$REPLY" -eq "quit" || "$REPLY" -eq "QUIT" ]]; then
    exit
  else
    echo "Invalid selection."
  fi
done

