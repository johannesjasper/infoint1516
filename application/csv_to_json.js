var fs = require('fs');
var csv = fs.readFileSync(process.argv[2], "utf8").split("\n").filter(a => a).map(a => a.split(",")).map(a => [a[0], Math.log(a[1])]);
var max = Math.max(...csv.map(a => a[1]));
var min = Math.min(...csv.map(a => a[1]));

var result = {};
csv.forEach((a) => {
  result[a[0]] = {
    'fillKey': Math.floor(9.9 * (a[1] - min) / (max - min))
  };
});
console.log(JSON.stringify(result));