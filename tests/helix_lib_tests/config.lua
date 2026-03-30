--- Test configuration — used to validate helix_lib Config.load() reads this correctly
return {
    testString = 'hello_helix',
    testNumber = 42,
    testBool = true,
    nested = {
        deep = {
            value = 'found_it',
        },
        array = { 1, 2, 3 },
    },
}
