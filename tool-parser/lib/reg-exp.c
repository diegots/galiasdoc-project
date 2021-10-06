/*
 * GaliasDoc: information extraction from PDF sources with common templates
 * Copyright (C) 2021 Diego Trabazo Sardón
 *
 * This file is part of GaliasDoc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>
 */

#define PCRE2_CODE_UNIT_WIDTH 8

#include "reg-exp.h"

#include <string.h>
#include <stdio.h>
#include <pcre2.h>

void *get_compiled_pattern(char *pattern_) {

    pcre2_code *re;
    PCRE2_SPTR pattern;     /* PCRE2_SPTR is a pointer to unsigned code units of */

    int errornumber;

    PCRE2_SIZE erroroffset;

    pattern = (PCRE2_SPTR) pattern_;

    re = pcre2_compile(
      pattern,               /* the pattern */
      PCRE2_ZERO_TERMINATED, /* indicates pattern is zero-terminated */
      0,                     /* default options */
      &errornumber,          /* for error number */
      &erroroffset,          /* for error offset */
      NULL);                 /* use default compile context */

      /* Compilation failed: print the error message and exit. */
      if (re == NULL) {
          PCRE2_UCHAR buffer[256];
          pcre2_get_error_message(errornumber, buffer, sizeof(buffer));
          printf("PCRE2 compilation failed at offset %d: %s\n", (int)erroroffset, buffer);
      }

      return re;
}

int reg_exp_find(void *re, char *subject_, bool *was_found) {

    PCRE2_SPTR subject;     /* the appropriate width (8, 16, or 32 bits). */

    // int i;
    int rc;

    // PCRE2_SIZE *ovector;

    size_t subject_length;
    pcre2_match_data *match_data;

    subject = (PCRE2_SPTR) subject_;
    subject_length = strlen((char *)subject);

    match_data = pcre2_match_data_create_from_pattern(re, NULL);

    rc = pcre2_match(
            re,                   /* the compiled pattern */
            subject,              /* the subject string */
            subject_length,       /* the length of the subject */
            0,                    /* start at offset 0 in the subject */
            0,                    /* default options */
            match_data,           /* block for storing the result */
            NULL);                /* use default match context */

    if (rc < 0) {
        switch(rc) {
            case PCRE2_ERROR_NOMATCH:
                //printf("No match\n");
                *was_found = false;
                break;
            /*
            Handle other special cases if you like
            */
            default: printf("Matching error %d\n", rc); break;
        }

        pcre2_match_data_free(match_data);   /* Release memory used for the match */
        pcre2_code_free(re);                 /* data and the compiled pattern. */
        return 1;
    }

    *was_found = true;
    pcre2_get_ovector_pointer(match_data);
    // ovector = pcre2_get_ovector_pointer(match_data);
    //printf("\nMatch succeeded at offset %d\n", (int)ovector[0]);

    /*************************************************************************
    * We have found the first match within the subject string. If the output *
    * vector wasn't big enough, say so. Then output any substrings that were *
    * captured.                                                              *
    *************************************************************************/

    /* The output vector wasn't big enough. This should not happen, because we used
    pcre2_match_data_create_from_pattern() above. */

    if (rc == 0) {
        printf("ovector was not big enough for all the captured substrings\n");
    }

    /* Show substrings stored in the output vector by number. Obviously, in a real
    application you might want to do things other than print them. */

    // for (i = 0; i < rc; i++) {
    //     PCRE2_SPTR substring_start = subject + ovector[2*i];
    //     size_t substring_length = ovector[2*i+1] - ovector[2*i];
    //     printf("%2d: %.*s\n", i, (int)substring_length, (char *)substring_start);
    // }

    return 0;
}
