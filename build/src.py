import json

# ---- file ----


def parse(data):
    transition = []
    start_state = data["dfa"]["initialState"]
    final_state = data["dfa"]["finalStates"]
    states = data["dfa"]["states"]
    for i in states:
        transition.append([i, '0', data["dfa"]["transitions"][i]['0']])
        transition.append([i, '1', data["dfa"]["transitions"][i]['1']])

    alphabet = ['0', '1']
    list_state = [start_state, states, final_state, transition, alphabet]
    return list_state


def readfile(path):
    with open(path, 'r') as f:
        return parse(json.load(f))


def writeFile(path, data):
    with open(path, 'w') as f:
        f.write(data)

# ---- helpers ----


def findUnreachableState(states, startState, transitions):
    state_unreachable = []

    states = [i for i in states if i not in startState]

    for i in states:
        check = False
        for j in range(len(transitions)):
            nextStates = transitions[j][2]
            if i == nextStates and check == False:
                check = True  # break from loop
        if check == False:
            state_unreachable.append(i)

    return state_unreachable


def removeUnreachableState(states, state_unreachable):
    temp_states = states.copy()
    for i in state_unreachable:
        temp_states.remove(i)

    return temp_states


def checkListEqual(ls1, ls2):
    count = 0

    while True:
        if count < len(ls1) and ls1[count] in ls2:
            count += 1
        elif count == len(ls1):
            return True
        else:
            return False


def stateSamePartition(ls_temp_copy):

    ls_same_partition = []
    ls_temp_copy = ls_temp_copy.copy()
    i = 0

    while len(ls_temp_copy) > 0:
        ii = ls_temp_copy[i]
        temp_list = [ii[0]]
        j = 1

        while j < len(ls_temp_copy):
            jj = ls_temp_copy[j]
            count = 0

            for k in ii[1]:
                if k in jj[1]:
                    count += 1

            if count != 0:
                temp_list.append(jj[0])
                ls_temp_copy.pop(j)
            else:
                j += 1

        if len(temp_list) == 1:
            ls_same_partition.append([ii[0]])
        elif len(temp_list) != 1:
            ls_same_partition.append(sorted(list(set(temp_list))))

        ls_temp_copy.pop(i)

    return ls_same_partition


def findTransitions(x, transitions, alphabet):  # b
    listFind = []
    check = True
    length = 0
    t = 0

    while check == True and length < len(transitions):
        i = transitions[length]
        dataFind = []

        if x == i[0]:
            for j in range(1, len(i)):
                dataFind.append(i[j])
            listFind.append(tuple(dataFind))
            t += 1

        if t == len(alphabet):
            check = False
        else:
            length += 1

    return listFind


def sortKey(tuple):
    return tuple[0]


def stateSame(ls_temp, ls_temp2, ls_state):
    ls_same_partition = []
    ls_temp2_copy = ls_temp2.copy()
    i = 0

    # check first place with the rest
    while len(ls_temp2_copy) > 0:
        ii = ls_temp2_copy[i]
        temp_list = [ii[0]]
        j = 1

        while j < len(ls_temp2_copy):
            jj = ls_temp2_copy[j]
            ii[1].sort(key=sortKey)
            jj[1].sort(key=sortKey)
            count_ls_state = 0
            check_ls = True
            temp_check_list1 = 0

            # check 2 state in list state
            # kiểm tra 2 trạng thái trong trạng thái danh sách
            while check_ls == True and count_ls_state < len(ls_state):
                temp_check_list2 = 0

                for k in range(len(ii[1])):

                    # test transition function with classes of subclass

                    if ii[1][k][1] in ls_state[count_ls_state] \
                            and jj[1][k][1] in ls_state[count_ls_state]:
                        temp_check_list1 += 1
                        temp_check_list2 += 1

                # all transfer functions (alphabets) of 2 states belong to the same class of partition,
                # the 2 states create a new class in the new partition
                # nếu tất cả các hàm truyền (bảng chữ cái) của 2 trạng thái đều thuộc cùng một lớp phân vùng,
                # 2 trạng thái tạo một lớp mới trong phân vùng mới
                if temp_check_list2 == len(ii[1]):
                    temp_list.append(jj[0])
                    ls_temp2_copy.pop(j)
                    check_ls = False
                # check next partition
                # kiểm tra phân vùng tiếp theo
                elif temp_check_list1 == len(ii[1]):
                    check_ls = False
                else:
                    count_ls_state += 1

            # each transfer function (alphabet) of 2 states belonging to the same class in the partition,
            # the 2 states create a new class in the new partition
            # nếu mỗi hàm chuyển (bảng chữ cái) của 2 trạng thái thuộc cùng một lớp trong phân vùng,
            # 2 trạng thái tạo một lớp mới trong phân vùng mới
            if temp_check_list1 == len(ii[1]) and temp_check_list1 != temp_check_list2:
                temp_list.append(jj[0])
                ls_temp2_copy.pop(j)

            # Nếu không kiểm tra với trạng thái tiếp theo
            elif temp_check_list1 != len(ii[1]):
                j += 1

        # add new class to partition
        # thêm lớp mới vào phân vùng
        if len(temp_list) == 1:
            ls_same_partition.append([ii[0]])
        elif len(temp_list) != 1:
            ls_same_partition.append(sorted(list(set(temp_list))))

        ls_temp2_copy.pop(i)

    return ls_same_partition


def getPartition(startState, finalStates, states, alphabet, transitions):

    state_unreachable = findUnreachableState(states, startState, transitions)
    temp_states = removeUnreachableState(states, state_unreachable)

    liststate = []
    ls_00 = finalStates
    ls_01 = [i for i in temp_states if i not in finalStates]
    ls_0 = [ls_00, ls_01]

    liststate.append(ls_0)

    temp_liststate = liststate.copy()

    ls_not_final = []

    ls_full_final = []

    ls_temp = []
    ls_temp2 = []

    for i in temp_liststate[0][1]:  # grouping states
        list_next_state = []
        list_next_trans = []

        for j in transitions:
            if i == j[0]:
                list_next_state.append(j[2])

                list_next_trans.append((j[1], j[2]))

        list_check_state = [k for k in list_next_state if k in finalStates]

        if len(list_check_state) == 0:  # dosent go to final state
            ls_not_final.append(i)

        elif len(list_check_state) == len(list_next_state):  # all transition go to final state
            ls_full_final.append(i)

        else:  # At least one state go to finial states
            ls_temp.append(i)
            ls_temp2.append((i, list_next_trans))

    ls_temp_lists_final = stateSamePartition(ls_temp2)
    ls_temp_lists_final.append(ls_00)
    ls_temp_lists_final.append(ls_full_final)
    ls_temp_lists_final.append(ls_not_final)

    # create second  partition
    ls_1 = ls_temp_lists_final.copy()

    # remove empty list
    if [] in ls_1:
        ls_1.remove([])

    # add second  partition
    liststate.append(ls_1)

    if checkListEqual(liststate[0], liststate[1]) == True:
        return liststate[0]

    else:
        check = True
        while check:
            new_temp_list = []
            length = len(liststate) - 1  # i can use without it

            for i in liststate[length]:  # liststate[-1]
                temp_i = []
                temp_tran_i = []

                # find new subclasses for classes with more than 2 states

                if len(i) > 2:
                    for j in i:
                        if j not in state_unreachable:
                            temp_i.append(j)
                            temp_tran_i.append(
                                (j, findTransitions(j, transitions, alphabet)))

                # For subclasses less than 2 states,
                # new partitions can be added

                if len(temp_tran_i) == 0:
                    new_temp_list.append(i)

                # handle finding new subclasses for classes with more than 2 states

                else:

                    for j in stateSame(temp_i, temp_tran_i, liststate[length]):
                        new_temp_list.append(j)

            # check if 2 lists are equal
            # If 2 consecutive partitions are equal, return that partition

            if checkListEqual(liststate[length], new_temp_list) == True:
                return liststate[length]
            else:
                liststate.append(new_temp_list)


def getListEquivalenceStates(listState):
    listEqui = []
    for i in listState:
        if len(i) > 1:
            listEqui.append(tuple(i))

    return listEqui


def removeUnreachableTransition(state_unreachable, transitions):
    temp_tran = transitions.copy()
    check_tran = True
    for i in state_unreachable:
        k = 0
        while check_tran == True:
            if k < len(temp_tran) and i == temp_tran[k][0]:
                temp_tran.pop(k)
            else:
                if k < len(temp_tran) - 1:
                    k += 1
                else:
                    check_tran = False
    return temp_tran


def dfaMinimization(f):
    startState = f[0]
    states = f[1]
    finalStates = f[2]
    transitions = f[3]
    alphabets = f[4]

    listState = getPartition(startState, finalStates,
                             states, alphabets, transitions)

    list_equi = getListEquivalenceStates(listState)

    state_unreachable = findUnreachableState(states, startState, transitions)

    if len(list_equi) == 0:
        pass
    else:
        check_start = True
        start_index = 0
        start = startState[0]

        while check_start == True and start_index <= len(list_equi):
            if start_index < len(list_equi) and start in list_equi[start_index] and check_start == True:
                startState = tuple(list_equi[start_index])
                check_start = False
            elif start_index < len(list_equi) - 1:
                start_index += 1
            else:
                check_start = False

    if len(list_equi) == 0:
        pass
    else:
        dfa_final = []

        for i in finalStates:
            check_final = True
            final_index = 0

            while check_final == True and final_index <= len(list_equi):
                if final_index < len(list_equi) and i in list_equi[final_index]:
                    dfa_final.append(tuple(list_equi[final_index]))
                    check_final = False
                else:
                    if final_index == len(list_equi) - 1 or len(list_equi) == 0:
                        dfa_final.append(i)
                        check_final = False
                    else:
                        final_index += 1

        finalStates = list(set(dfa_final))

    temp_states = states.copy()
    for i in state_unreachable:
        temp_states.remove(i)

    for i in list_equi:
        id_state = 0
        while id_state < len(temp_states):
            if temp_states[id_state] in i:
                temp_states.pop(id_state)
            else:
                id_state += 1
        temp_states.append(i)

    states = temp_states

    dfa_transitions = transitions

    if len(list_equi) == 0:
        dfa_transitions = transitions.copy()
    else:
        temp_list_equi = list_equi.copy()
        temp_tran = removeUnreachableTransition(state_unreachable, transitions)

        for i in temp_list_equi:
            for j in temp_tran:
                if j[0] in i:
                    j[0] = i
                if j[2] in i:
                    j[2] = i

        # remove transition loop
        i = 0
        while i < len(temp_tran) - 1:
            ii = temp_tran[i]
            j = i + 1
            while j < len(temp_tran):
                jj = temp_tran[j]

                if ii == jj:
                    temp_tran.pop(j)
                else:
                    j += 1
            i += 1

    states = []
    for i in temp_tran:
        if i[0] not in states:
            states.append(i[0])

    result = {"dfa": {"states": states, "alphabet": alphabets,
                      "transitions": temp_tran, "initialState": startState, "finalStates": finalStates}}
    return result

# ---- test ----

PATH = "C:/Users/HamidB80/Downloads/dfa.json"
# writeFile("output.json", json.dumps(dfaMinimization(readfile(PATH))))

# ---- entry ----


def entry(s):
    result = json.dumps(dfaMinimization(parse(json.loads(s))))
    print("result:")
    print(result)
    return result


# ---- export ----
entry
