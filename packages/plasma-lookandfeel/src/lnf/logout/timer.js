.pragma library
var callbacks = [];
function addCancelAutoTriggerCallback(callback) {
    callbacks.push(callback);
}
function cancelAutoTrigger() {
    callbacks.forEach(function (c) {
        if (c) {
            c();
        }
    });
}
