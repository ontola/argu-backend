
function OrderedMap() {
    this._map = new Map();
    this._array = [];

    this.length = this._array.length;
}

OrderedMap.prototype.descending = function (a, b) {
    return new Date(b) - new Date(a);
};

OrderedMap.prototype.merge = function (property, array) {
    array.forEach(item => {
        this.set(item[property], item);
    });
};

OrderedMap.prototype.get = function(key) {
    if (typeof key === 'number') {
        return this._map.get(this._array[key])
    } else {
        return this._map.get(key);
    }
};

OrderedMap.prototype.map = function (f) {
    let i = -1;
    return this._array.sort(this.descending).map(date => f(this._map.get(date), ++i));
};


OrderedMap.prototype.remove = function(key) {
    const index = this._array.indexOf(key);
    if (index === -1) {
        throw new Error('key does not exist');
    }
    this._array.splice(index, 1);
    delete this.map[key];
    this.length = this._array.length
};

OrderedMap.prototype.set = function(key, value) {
    if (key in this._map === false) {
        this._array.push(key);
    }
    this._map.set(key, value);
    this.length = this._array.length
};

export default OrderedMap;
