. ~/.bashrc
echo -n "${PS1@P}"
echo ${INDIRECT_CMD} | pv -qL 10
eval "${INDIRECT_CMD}"
echo -n "${PS1@P}"
sleep 2
echo 
exit 0
