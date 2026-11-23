
% ================ PREDICATES ================ %

% 1. secondMin(+List, -Min2): Min2 is the second lowest unique number in List.
% First non-number -> print an error and fail. Then sort with mySort
% (which also drops duplicates) and take the 2nd item. Fewer than two
% unique values -> print an error and fail. Does not use sort/2.
secondMin(List, Min2) :-
    (   secondmin_first_non_number(List, Bad)
    ->  format(atom(Message), 'ERROR: "~w" is not a number.', [Bad]),
        writeln(Message),
        fail
    ;   mySort(List, Sorted),
        (   Sorted = [_, Second | _]
        ->  Min2 = Second
        ;   writeln('ERROR: List has fewer than two unique elements.'),
            fail
        )
    ).

% secondmin_first_non_number(+List, -Bad): Bad is the first non-number.
% Fails if every element is a number.
secondmin_first_non_number([Head | Tail], Bad) :-
    (   number(Head)
    ->  secondmin_first_non_number(Tail, Bad)
    ;   Bad = Head
    ).

% mySort(+List, -Sorted): insertion sort, ascending, duplicates removed.
mySort([], []).
mySort([Head | Tail], Sorted) :-
    mySort(Tail, SortedTail),
    mysort_insert(SortedTail, Head, Sorted).

% mysort_insert(+SortedList, +Item, -Result): put Item in its place,
% dropping it if an equal value is already there.
% The list comes first so Prolog picks the clause without a choicepoint.
mysort_insert([], Item, [Item]).
mysort_insert([Top | Rest], Item, Result) :-
    (   Item =:= Top
    ->  Result = [Top | Rest]
    ;   Item < Top
    ->  Result = [Item, Top | Rest]
    ;   Result = [Top | NewRest],
        mysort_insert(Rest, Item, NewRest)
    ).

% 2. classify(+List, +TestPredicate, -Pass, -Fail): split List into the
% items that pass TestPredicate and the items that fail it, keeping order.
% Empty list -> two empty lists. Otherwise test the head with call/2,
% put it on the front of the right basket, and classify the tail.
classify([], _, [], []).
classify([Head | Tail], Test, Pass, Fail) :-
    (   call(Test, Head)
    ->  Pass = [Head | PassRest],
        Fail = FailRest
    ;   Pass = PassRest,
        Fail = [Head | FailRest]
    ),
    classify(Tail, Test, PassRest, FailRest).

% 3. subslice(+List1, +List2): true if List1 appears as a contiguous
% run of elements anywhere in List2.
% Try every suffix of List2; succeed if one starts with List1.
% once/1 stops after the first match since this is a yes/no test.
subslice(Sub, List) :-
    once((
        append(_, Suffix, List),
        append(Sub, _, Suffix)
    )).

% 4. shift(+List, +Integer, -Shifted): rotate List N places left
% (negative N rotates right). N mod Length gives the cut point, then
% the deck is cut into Front and Back and reassembled as Back + Front.
% An empty list stays empty (avoids mod by zero).
shift(List, N, Shifted) :-
    length(List, Length),
    (   Length =:= 0
    ->  Shifted = []
    ;   CutPoint is N mod Length,
        length(Front, CutPoint),
        append(Front, Back, List),
        append(Back, Front, Shifted)
    ).

% 5. luhn(+Integer): true if Number passes the Luhn checksum.
% Walk digits right to left, doubling every 2nd digit (a doubled
% 2-digit result has its digits added). Valid if the total ends in 0.
luhn(Number) :-
    integer(Number),
    Number >= 0,
    luhn_sum(Number, false, Sum),
    Sum mod 10 =:= 0.

% luhn_sum(+Remaining, +ShouldDouble, -Sum): total of the Luhn digit values.
luhn_sum(Remaining, ShouldDouble, Sum) :-
    (   Remaining =:= 0
    ->  Sum = 0
    ;   Digit is Remaining mod 10,
        Rest is Remaining // 10,
        luhn_digit_value(ShouldDouble, Digit, Value),
        luhn_flip(ShouldDouble, NextShouldDouble),
        luhn_sum(Rest, NextShouldDouble, RestSum),
        Sum is Value + RestSum
    ).

% luhn_digit_value(+ShouldDouble, +Digit, -Value)
% Flag comes first so Prolog picks the right clause without a choicepoint.
luhn_digit_value(false, Digit, Digit).
luhn_digit_value(true, Digit, Value) :-
    Doubled is Digit * 2,
    Value is Doubled // 10 + Doubled mod 10.

% luhn_flip(+Flag, -Flipped)
luhn_flip(true, false).
luhn_flip(false, true).

% 6. path(+Node1, +Node2) and cycle(+Node) over directed edge/2 facts.
% The edges come from the grader, so none are defined here. The dynamic
% declaration lets the file load and answer false when no edges exist.
:- dynamic edge/2.

% path(+From, +To): true if To can be reached from From.
% Tracks visited nodes so cycles in the graph can't cause infinite recursion.
% once/1 stops at the first route found, since this is a yes/no test.
path(From, To) :-
    once(path_search(From, To, [From])).

% path_search(+From, +To, +Visited)
path_search(From, To, _) :-
    edge(From, To).
path_search(From, To, Visited) :-
    edge(From, Next),
    \+ memberchk(Next, Visited),
    path_search(Next, To, [Next | Visited]).

% cycle(+Node): true if a path leads from Node back to Node.
cycle(Node) :-
    path(Node, Node).



% ================ TESTS ================ %
% Run with: ?- run_tests.

% secondMin tests %
:- begin_tests(secondMin).

test(spec_basic) :- secondMin([17,29,11,62,37,53], 17).
test(spec_negatives) :- secondMin([7,5.2,3,6,-3.6,9,-2], -2).
test(duplicate_smallest) :- secondMin([1,1,2], 2).
test(two_items) :- secondMin([9,2], 9).

test(spec_one_item) :-
    with_output_to(string(Out), \+ secondMin([512], _)),
    Out == "ERROR: List has fewer than two unique elements.\n".
test(spec_all_same) :-
    with_output_to(string(Out), \+ secondMin([3,3,3], _)),
    Out == "ERROR: List has fewer than two unique elements.\n".
test(empty) :-
    with_output_to(string(Out), \+ secondMin([], _)),
    Out == "ERROR: List has fewer than two unique elements.\n".
test(spec_non_number) :-
    with_output_to(string(Out), \+ secondMin([12,2,b,7], _)),
    Out == "ERROR: \"b\" is not a number.\n".
test(first_non_number_only) :-
    with_output_to(string(Out), \+ secondMin([1,x,y], _)),
    Out == "ERROR: \"x\" is not a number.\n".

test(mysort) :- mySort([3,1,2,3,1], [1,2,3]).

:- end_tests(secondMin).

% classify tests %
:- begin_tests(classify).

test(even_lambda) :-
    classify([8,7,6,5,4,3], [X]>>(0 is X mod 2), [8,6,4], [7,5,3]).
test(integer) :-
    classify([-4, 11.2, "hi", 9, 0], integer, [-4,9,0], [11.2,"hi"]).
test(number) :-
    classify([-4, 11.2, "hi", 9, 0], number, [-4,11.2,9,0], ["hi"]).
test(empty_undefined_test) :-
    classify([], odd, [], []).
test(all_pass) :-
    classify([a,b,c], atom, [a,b,c], []).
test(all_fail) :-
    classify([1,2,3], atom, [], [1,2,3]).
test(string) :-
    classify(["a", 1, "b", x], string, ["a","b"], [1,x]).

:- end_tests(classify).

% Subslice tests %
:- begin_tests(subslice).

test(middle) :- subslice([2,3,4], [1,2,3,4]).
test(inner) :- subslice([8,13], [3,4,8,13,7]).
test(missing, [fail]) :- subslice([3], [1,2,4]).
test(empty_sub) :- subslice([], [1,2,4]).
test(empty_list, [fail]) :- subslice([1,2,4], []).
test(whole_list) :- subslice([1,2,4], [1,2,4]).
test(at_end) :- subslice([4,5], [1,2,4,5]).
test(appears_twice) :- subslice([1], [1,2,1]).
test(not_contiguous, [fail]) :- subslice([1,3], [1,2,3]).
test(both_empty) :- subslice([], []).

:- end_tests(subslice).

% Shift tests %
:- begin_tests(shift).

test(left_three) :- shift([a,b,c,d,e,f,g,h], 3, [d,e,f,g,h,a,b,c]).
test(left_one) :- shift([1,2,3,4,5], 1, [2,3,4,5,1]).
test(right_two) :- shift([a,b,c,d,e,f,g,h], -2, [g,h,a,b,c,d,e,f]).
test(zero) :- shift([1,2,3], 0, [1,2,3]).
test(full_turn) :- shift([1,2,3], 3, [1,2,3]).
test(more_than_length) :- shift([1,2,3], 4, [2,3,1]).
test(big_negative) :- shift([1,2,3], -4, [3,1,2]).
test(empty) :- shift([], 5, []).
test(single) :- shift([x], 7, [x]).

:- end_tests(shift).

% Luhn tests %
:- begin_tests(luhn).

test(valid_long) :- luhn(799273987104).
test(valid_spec) :- luhn(49927398716).
test(valid_short) :- luhn(59).
test(invalid_spec, [fail]) :- luhn(49927398717).
test(invalid_other, [fail]) :- luhn(79927398710).
test(not_integer, [fail]) :- luhn(abc).

:- end_tests(luhn).

% Path and cycle tests %
:- begin_tests(graph).

% Loads the spec's example graph (for testing only), replacing any edges.
load_example_graph :-
    retractall(user:edge(_, _)),
    forall(member(E, [edge(a,b), edge(b,c), edge(c,d), edge(d,a), edge(d,e), edge(b,a)]),
           assertz(user:E)).

clear_graph :- retractall(user:edge(_, _)).

test(spec_path_b_d, [setup(load_example_graph), cleanup(clear_graph)]) :- path(b, d).
test(spec_path_e_b, [setup(load_example_graph), cleanup(clear_graph), fail]) :- path(e, b).
test(spec_path_c_a, [setup(load_example_graph), cleanup(clear_graph)]) :- path(c, a).
test(spec_cycle_b, [setup(load_example_graph), cleanup(clear_graph)]) :- cycle(b).
test(spec_cycle_e, [setup(load_example_graph), cleanup(clear_graph), fail]) :- cycle(e).
test(path_to_dead_end, [setup(load_example_graph), cleanup(clear_graph)]) :- path(a, e).
test(unknown_node, [setup(load_example_graph), cleanup(clear_graph), fail]) :- path(a, z).
test(no_edges, [setup(clear_graph), fail]) :- path(a, b).

:- end_tests(graph).
