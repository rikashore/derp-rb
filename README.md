# derp-rb
A ruby based interpreter for derplang. https://esolangs.org/wiki/Derplang

derp-rb fully supports all the built-in commands for derplang as defined [here](https://esolangs.org/wiki/Derplang#Commands) alongside a few of its own.

## New commands
These are the new commands under derp-rb

### unset
`unset` allows you to unset the value of a variable. For example

```
va:x:10:ou:x:un:x:
```

Would set the value of `x` to 10, print it and then unset its value. attempting to use the variable again would raise an error.

### in
`in` works similar to `ip` but with the added functionality of allowing to set a prompt.

```
ip:number:x:
```

Would produce

```
number: 
```

and allow you to take user input.

## Default labels
As an added feature, the `END` label is added, which when used will take you to the end of the program and ending execution.

## Acknowledgements
This project was heavily inspired by [derpi](https://github.com/jessehorne/derpi)
