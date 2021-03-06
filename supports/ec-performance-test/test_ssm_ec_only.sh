#!/usr/bin/env bash
# avoid blocking REST API
unset http_proxy
# for python use
export PYTHONPATH=../integration-test:$PYTHONPATH

echo "Get configuration from config."
source config
echo "------------------ Your configuration ------------------"
echo "SSM home is ${SMART_HOME}."
echo "PAT home is ${PAT_HOME}."
echo "Test case:"
for size in ${!CASES[@]}; do
  echo ${size} ${CASES[$size]}
done
echo "--------------------------------------------------------"

# Test ec conversion for 1 round
bin=$(dirname "${BASH_SOURCE-$0}")
bin=$(cd "${bin}">/dev/null; pwd)
log="${bin}/ssm.log"
# remove historical data in log file
printf "" > ${log}
for size in "${!CASES[@]}"; do    
    case="${size}_${CASES[$size]}"
    action="ec"	
    echo "Test case ${case}($action):" >> ${log}
    echo "==================== test case: $case, test round: 1 ============================"	
    sh drop_cache.sh    
    # make ssm log empty before test
    printf "" > ${SMART_HOME}/logs/smartserver.log
    cd ${PAT_HOME}/PAT-collecting-data
    echo "export PYTHONPATH=${bin}/../integration-test:${PYTHONPATH};\
    python ${bin}/run_ssm_ec.py ${size} ${CASES[$size]} ${log} ${action}" > cmd.sh
    ./pat run "${case}_${action}"        
    cp ${SMART_HOME}/logs/smartserver.log ./results/${case}-${action}.log
    cd ${bin}  
    printf "\nTest case ${case} is finished!\n" >> ${log}
done
