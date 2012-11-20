genetic-algorithm-erl
=====================

Generic implementation of genetic algorithm in Erlang.

Draft version.

Test from shell:
```erlang
ga:iterate(200, arr_ga:init_population(5), fun arr_ga:operator/1, fun arr_ga:fit/1, 1).
```
