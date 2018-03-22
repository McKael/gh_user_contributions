# gh_user_contributions

This repository contains a small shell script (bash/zsh) that can be used to
display the number of "contributions" of a Github user.

(Not that contribution numbers have a real value, see for example
[this Github page](https://help.github.com/articles/viewing-contributions-on-your-profile/).)

A few usage examples:

```
## Get Kelsey Hightower's contribution statistics
% ./gh_user_contributions.sh kelseyhightower
* 2018-03-22: 1375
* 2017-03-22: 1140
* 2016-03-22: 742
* 2015-03-22: 941
* 2014-03-22: 320
* 2013-03-22: 45
* 2012-03-22: 32
* 2011-03-22: 0
Total contributions:
4595

## Get only the last 2 years
% ./gh_user_contributions.sh kelseyhightower 2
* 2018-03-22: 1375
* 2017-03-22: 1140
Total contributions:
2515

## Get only the total result by redirecting stderr
% ./gh_user_contributions.sh torvalds 2>/dev/null
24

# (Yeah, he's new to git...)
```
