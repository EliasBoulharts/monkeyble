#/bin/bash
set -e #

RED='\033[0;31m'
GREEN='\033[0;32m'
ANSIBLE_CMD="ANSIBLE_CONFIG="../../ansible.cfg" ansible-playbook-6 -v"

function assert_playbook_fail () {
  # $1: playbook path
  # $2: vars path
  # $3: list scenario

  PLAYBOOK_PATH=$1
  VARS_PATH=$2
  LIST_SCENARIO=("$@")

  for scenario in ${LIST_SCENARIO[@]}; do
    echo "Run Monkeyble scenario: $scenario"
    # Run the test and capture the returned error code
    if eval $ANSIBLE_CMD \
    $PLAYBOOK_PATH \
    -e "@${VARS_PATH}" \
    -e "monkeyble_scenario=$scenario"
    then
      printf  "❌ ${RED}Monkeyble scenario '$scenario' has not failed as expected${NC}\n"
      exit 1
    else
      printf  "✔️${GREEN}Monkeyble check fail success${NC}\n"
    fi
    echo "###########################"
  done

}

echo "Monkeyble test input passed..."
eval $ANSIBLE_CMD \
test_input/playbook.yml \
-e "@test_input/test_asserts_passed/vars.yml" \
-e "monkeyble_scenario=validate_test_passed"

echo "Monkeyble test input failed..."
LIST_SCENARIO=(
  "test_assert_equal"
  "test_assert_not_equal"
  "test_assert_in_with_list"
  "test_assert_in_with_string"
  "test_assert_true"
  "test_assert_false"
  "assert_is_none"
  "assert_is_not_none"
  "assert_list_equal"
  "assert_dict_equal"
)
PLAYBOOK_PATH="test_input/playbook.yml"
VARS_PATH="test_input/test_asserts_failed/vars.yml"
assert_playbook_fail $PLAYBOOK_PATH $VARS_PATH "${LIST_SCENARIO[@]}"

echo "Monkeyble test state passed..."
eval $ANSIBLE_CMD \
test_task_state/playbook.yml \
-e "@test_task_state/test_state_passed/vars.yml" \
-e "monkeyble_scenario=validate_test_passed"

echo "Monkeyble test state failed..."
LIST_SCENARIO=(
  "should_be_changed_false"
  "should_be_changed_true"
  "should_be_skipped"
  "should_not_be_skipped"
  "should_failed"
  "should_not_failed"
)
PLAYBOOK_PATH="test_task_state/playbook.yml"
VARS_PATH="test_task_state/test_state_failed/vars.yml"
assert_playbook_fail $PLAYBOOK_PATH $VARS_PATH "${LIST_SCENARIO[@]}"
