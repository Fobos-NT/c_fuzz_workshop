#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "json.h"

int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
    json_char* json;
    json_value* value;

    json = malloc(size + 1);
    if (json == NULL) {
        return 0;
    }

    memcpy(json, data, size);
    json[size] = '\0';

    value = json_parse(json, size);

    if (value == NULL) {
        free(json);
        return 0;
    }

    json_value_free(value);
    free(json);

    return 0;
}