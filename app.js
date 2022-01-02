var input = {
    "num1" : 240257,
    "num2" : 17323,
};

var dictstring = JSON.stringify(input);

var fs = require('fs');
fs.writeFile("./main_js/input.json", dictstring, function(err, result) {
    if(err) console.log('error in creeating input.json', err);
});