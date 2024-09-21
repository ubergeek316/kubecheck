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
#purple() {
#    echo "\033[35m$@\033[0m"
#    };

# Displays the output of the kubectl commands
display_kubernetes() {
echo -e "${BOLD_GREEN}-----[Pods]\n${BOLD_MAGENTA}";
kubectl get pods|tail -n 10
echo -e "${BOLD_GREEN}-----[Services]\n${BOLD_MAGENTA}";
kubectl get services|tail -n 10
echo -e "${BOLD_GREEN}-----[Deployment]\n${BOLD_MAGENTA}";
kubectl get deployments|tail -n 10
echo -e "${BOLD_GREEN}-----[Events]\n${BOLD_MAGENTA}";
kubectl events|tail -n 9
echo -e"${BOLD_GREEN}-----[Logs]\n${BOLD_MAGENTA}";
if [ ! -z $1 ]; then
    kubectl logs $1 |tail -n 9
fi
echo -e "${BOLD_GREEN}-----[persistentvolumeclaims]\n${BOLD_MAGENTA}";
kubectl get persistentvolumeclaims
echo -e "${BOLD_GREEN}-----[persistentvolumes]\n${BOLD_MAGENTA}";
kubectl get persistentvolumes
}

# Export the function so it can be used by watch
#export -f purple
unset display_kubernetes
declare -f display_kubernetes
export -f display_kubernetes

# Watch the output of the kubectl commands
watch -c display_kubernetes
