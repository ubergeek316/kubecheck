# Foreground colors:
# Black: \033[30m
# Red: \033[31m
# Green: \033[32m
# Yellow: \033[33m
# Blue: \033[34m
# Magenta (purple): \033[35m
# Cyan: \033[36m
# White: \033[37m
# Background colors:
# Black: \033[40m
# Red: \033[41m
# Green: \033[42m
# Yellow: \033[43m
# Blue: \033[44m
# Magenta (purple): \033[45m
# Cyan: \033[46m
# White: \033[47m
# Text styles:
# Bold: \033[1m
# Italic: \033[3m
# Underline: \033[4m

# Colors Text Purple
purple() {
    echo "\033[35m$@\033[0m"
    };

# Displays the output of the kubectl commands
display_kubernetes() {
echo "-----[Pods]";
purple "$(kubectl get pods|tail -n 10)"
echo "-----[Services]";
purple "$(kubectl get services|tail -n 10)";
echo "-----[Deployment]";
purple "$(kubectl get deployments|tail -n 10)";
echo "-----[Events]";
purple "$(kubectl events|tail -n 9)";
echo "-----[Logs]";
purple "$(kubectl logs deployments/dingdong2|tail -n 9)";
echo "-----[persistentvolumeclaims]";
purple "$(kubectl get persistentvolumeclaims)";
echo "-----[persistentvolumes]";
purple "$(kubectl get persistentvolumes)";
}

# Export the function so it can be used by watch
export -f purple
export -f display_kubernetes

# Watch the output of the kubectl commands
watch -c display_kubernetes