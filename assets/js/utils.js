/*http://qmlbook.github.io */
var _component;
var _callback;
var _parent;
var _source;

//http://qmlbook.github.io
function createObject(source, parent, callback) {
    _parent = parent;
    if (callback)
        _callback = callback;
    _source = source;

    _component = Qt.createComponent(source);
    if (_component.status === Component.Ready || _component.status === Component.Error) {
        var obj = createObjectDone();
        return obj;
    }
    else
        _component.statusChanged.connect(createObjectDone);
}

//http://qmlbook.github.io
function createObjectDone() {
    if (_component.status === Component.Ready) {
        var obj = _component.createObject(_parent);
        if (obj != null) {
            if (_callback)
                _callback(obj, _source);
            return obj;
        }
        else
            console.log("Error creating object: " + _source);

        _component.destroy();        
    }
    else if (_component.status === Component.Error)
        console.log("Error creating component: " + component.errorString());

    return 0;
}

function shuffle(array) {
  var m = array.length, t, i;

    while (m) {
        i = Math.floor(Math.random() * m--);
        t = array[m];
        array[m] = array[i];
        array[i] = t;
    }

  return array;
}


function getAvg(arr) {
    var sum = arr.reduce(function(a, b) { return a + b; });
    return sum / times.length;
}


function overItem(item, x, y, tolerance) {
    var position = root.mapToGlobal(x, y);
    var globalItemPos = item.mapToItem(root, 0, 0);

    if (item.objectName === "topLayout")
        return (position.x > globalItemPos.x - tolerance/2 && position.x < (globalItemPos.x + item.width + tolerance/2) &&
               position.y > globalItemPos.y - tolerance && position.y < (globalItemPos.y + item.height));
    else if (item.objectName === "bottomLayout")
        return (position.x > globalItemPos.x - tolerance/2 && position.x < (globalItemPos.x + item.width + tolerance/2) &&
               position.y > globalItemPos.y-10 && position.y < (globalItemPos.y + item.height + tolerance));
    else
        return (position.x > globalItemPos.x - tolerance/2 && position.x < (globalItemPos.x + item.width + tolerance/2) &&
               position.y > globalItemPos.y - tolerance/2 && position.y < (globalItemPos.y + item.height + tolerance/2));
}


function newObject(path, args, parent) {
    if (!args)
        args = {};

    args.parent = parent;
    var component = Qt.createComponent(path);
    if (component.status === QtQuick.Component.Error) {

        print("Unable to load object: " + path + "\n" + component.errorString());
        return null;
    }

    return component.createObject(parent, args);
}


function findRoot(obj) {
    while (obj.parent) {
        obj = obj.parent;
    }

    return obj;
}


function findRootChild(obj, objectName) {
    obj = findRoot(obj);

    var childs = new Array(0);
    childs.push(obj);
    while (childs.length > 0) {
        if (childs[0].objectName == objectName) {
            return childs[0];
        }
        for (var i in childs[0].data) {
            childs.push(childs[0].data[i]);
        }
        childs.splice(0, 1);
    }
    return null;
}


function findChild(obj,objectName) {
    var childs = new Array(0);
    childs.push(obj);
    while (childs.length > 0) {
        if (childs[0].objectName == objectName) {
            return childs[0];
        }
        for (var i in childs[0].data) {
            childs.push(childs[0].data[i]);
        }
        childs.splice(0, 1);
    }

    return null;
}


/* Degree-to-pixel fixation radius
   parameters:
    - distance_from_screen(mm)
    - screen_diameter(inches)
    - screen_width(Horizontal screen resolution in pixels)
    - screen_height(Vertical screen resolution in pixels)
    - alpha(Fixation radius in degrees)
*/
function fixationRadius(distance, diameter, hresolution, vresolution, alpha) {    
    
    var a = alpha * Math.PI / 180;
    var p = distance * Math.tan(a) / ( (diameter * Math.sin(Math.atan(vresolution/hresolution)) * 25.4) / vresolution );    
    p = (Math.round(p * 100))/100; 

    return p;
}

function isEmpty(obj) {
    for(var prop in obj)
        if(obj.hasOwnProperty(prop))
            return false;

    return JSON.stringify(obj) === JSON.stringify({});
}

