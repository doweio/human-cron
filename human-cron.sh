#!/bin/bash
################################################
# bash script                                  #
# author Mikolaj 'Metatron' Niedbala           #
# displays user crontab in human readable form #
# based on `crontab` command                   #
# need to specify user                         #
# licenced GNU/ GPL                            #
#                                              #
# fork: https://github.com/doweio/human-cron   #
#                                              #
################################################

# create day of week lookup
# thanks to: don_crissti
# https://unix.stackexchange.com/questions/345724/converting-integer-to-day-of-week-using-date1
function getdayname () {
    local days=( Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday
               )
    re='^[0-9]+$'
    if ! [[ $1 =~ $re ]] ; then
        echo "Value passed should be numeric 0-7"
        exit
    else
        printf %s\\n ${days[$1]}
    fi
}

# change from user to file input
if [[ -z $1 ]]; then
    echo "Please supply a file to scan. Usage: human-cron.sh <filename>"
    exit 1;
fi;

echo -e "List of crons scheduled in $1\n\n"
grep upgrade-liverun $1 | while read line
    do
        if [[ ! $line =~ ^\# && ! -z $line && ! $line =~ ^MAILTO ]]; then
            COMBINED_DATE=0
            TIME_str=""
            DATE_str=""

            #explode to values
            COMMAND=`echo "$line" | sed 's/^\(.\{1,8\} \)\{5\}//' | awk '{print $2;}'`
            MINUTES=`echo "$line" |cut -d" " -f1`
            HOUR=`echo "$line" |cut -d" " -f2`
            MONTH_DAY=`echo "$line" |cut -d" " -f3`
            MONTH=`echo "$line" |cut -d" " -f4`
            WEEK_DAY=`echo "$line" |cut -d" " -f5`
            WEEK_DAY_NAME=`getdayname $WEEK_DAY`

            # echo DEBUG
            # echo "$line"
            # echo $WEEK_DAY
            # echo $WEEK_DAY_NAME
            # echo ENDDEBUG

            #command string
            ECHO_str="$COMMAND is scheduled"

            #process values
                #hours
                if [[ ! $HOUR =~ ^\*$ && ! -z $HOUR ]]; then
                    if [[ $HOUR =~ ^\*\/[0-9]{1,2}$ && ! -z $HOUR ]]; then
                        NUM_HOUR=`echo "$HOUR" |cut -d"/" -f2`;
                        HR_str="every $NUM_HOUR hours";
                    elif [[ $HOUR =~ ^[0-9]{1,2}$ && ! -z $HOUR ]]; then
                        HR_str="at $HOUR"
                        COMBINED_DATE=1
                    elif [[ $HOUR =~ ^[0-9]{1,2}-[0-9]{1,2}$ && ! -z $HOUR ]]; then
                        FR_NUM_HOUR=`echo "$HOUR" |cut -d"-" -f1`;
                        TO_NUM_HOUR=`echo "$HOUR" |cut -d"-" -f2`;
                        HR_str="between $FR_NUM_HOUR and $TO_NUM_HOUR"
                    elif [[ $HOUR =~ ^[0-9]{1,2}-[0-9]{1,2}\/[0-9]{1,2}$ && ! -z $HOUR ]]; then
                        NUM_HOUR=`echo "$HOUR" |cut -d"/" -f2`;
                        HOUR_RANGE=`echo "$HOUR" |cut -d"/" -f1`;
                        FR_NUM_HOUR=`echo "$HOUR_RANGE" |cut -d"-" -f1`;
                        TO_NUM_HOUR=`echo "$HOUR_RANGE" |cut -d"-" -f2`;
                        HR_str="between $FR_NUM_HOUR and $TO_NUM_HOUR, every $NUM_HOUR hours"
                    fi;
                else
                    HR_str=""
                fi;

                #minutes
                if [[ ! $MINUTES =~ ^\*$ && ! -z $MINUTES ]]; then
                    if [[ $MINUTES =~ ^\*\/[0-9]{1,2}$ && ! -z $MINUTES ]]; then
                        NUM_MINUTES=`echo "$MINUTES" |cut -d"/" -f2`
                        MIN_str="every $NUM_MINUTES minute"
                    elif [[ $COMBINED_DATE == 1 ]]; then
                        if [[ ! $MINUTES =~ ^\*$ && ! -z $MINUTES ]]; then
                            MIN_str="$MINUTES"
                        else
                            MIN_str="w $MINUTES minute"
                        fi;
                    elif [[ $MINUTES =~ ^[0-9]{1,2}-[0-9]{1,2}$ && ! -z $MINUTES ]]; then
                        FR_NUM_MINUTES=`echo "$MINUTES" |cut -d"-" -f1`;
                        TO_NUM_MINUTES=`echo "$MINUTES" |cut -d"-" -f2`;
                        MIN_str="between $FR_NUM_MINUTES and $TO_NUM_MINUTES minutes"
                    elif [[ $MINUTES =~ ^[0-9]{1,2}-[0-9]{1,2}\/[0-9]{1,2}$ && ! -z $MINUTES ]]; then
                        NUM_MINUTES=`echo "$MINUTES" |cut -d"/" -f2`;
                        MINUTES_RANGE=`echo "$MINUTES" |cut -d"/" -f1`;
                        FR_NUM_MINUTES=`echo "$MINUTES_RANGE" |cut -d"-" -f1`;
                        TO_NUM_MINUTES=`echo "$MINUTES_RANGE" |cut -d"-" -f2`;
                        MIN_str="between $FR_NUM_MINUTES and $TO_NUM_MINUTES minutes, every $NUM_MINUTES minutes"
                    fi;
                else
                    MIN_str=""
                fi;

                #day of month
                if [[ ! $MONTH_DAY =~ ^\*$ && ! -z $MONTH_DAY ]]; then
                    if [[ $MONTH_DAY =~ ^\*\/[0-9]{1,2}$ && ! -z $MONTH_DAY ]]; then
                        NUM_MONTH_DAY=`echo "$MONTH_DAY" |cut -d"/" -f2`
                        MON_D_str="every $NUM_MONTH_DAY days"
                    elif [[ $MONTH_DAY =~ ^[0-9]{1,2}$ && ! -z $MONTH_DAY ]]; then
                        MON_D_str="$MONTH_DAY days of the month"
                    elif [[ $MONTH_DAY =~ ^[0-9]{1,2}-[0-9]{1,2}$ && ! -z $MONTH_DAY ]]; then
                        FR_NUM_MONTH_DAY=`echo "$MONTH_DAY" |cut -d"-" -f1`;
                        TO_NUM_MONTH_DAY=`echo "$MONTH_DAY" |cut -d"-" -f2`;
                        MON_D_str="between days $FR_NUM_MONTH_DAY and $TO_NUM_MONTH_DAY of the month"
                    elif [[ $MONTH_DAY =~ ^[0-9]{1,2}-[0-9]{1,2}\/[0-9]{1,2}$ && ! -z $MONTH_DAY ]]; then
                        NUM_MONTH_DAY=`echo "$MONTH_DAY" |cut -d"/" -f2`;
                        MONTH_DAY_RANGE=`echo "$MONTH_DAY" |cut -d"/" -f1`;
                        FR_NUM_MONTH_DAY=`echo "$MONTH_DAY_RANGE" |cut -d"-" -f1`;
                        TO_NUM_MONTH_DAY=`echo "$MONTH_DAY_RANGE" |cut -d"-" -f2`;
                        MON_D_str="between days $FR_NUM_MONTH_DAY and $TO_NUM_MONTH_DAY of the month, every $NUM_MONTH_DAY days"
                    fi;
                else
                    MON_D_str=""
                fi;

                #month
                if [[ ! $MONTH =~ ^\*$ && ! -z $MONTH ]]; then
                    if [[ $MONTH =~ ^\*\/[0-9]{1,2}$ && ! -z $MONTH ]]; then
                        NUM_MONTH=`echo "$MONTH" |cut -d"/" -f2`
                        MON_str="every month $NUM_MONTH"
                    elif [[ $MONTH =~ ^[0-9]{1,2}$ && ! -z $MONTH ]]; then
                        MON_str="in $MONTH a month"
                    elif [[ $MONTH =~ ^[0-9]{1,2}-[0-9]{1,2}$ && ! -z $MONTH ]]; then
                        FR_NUM_MONTH=`echo "$MONTH" |cut -d"-" -f1`;
                        TO_NUM_MONTH=`echo "$MONTH" |cut -d"-" -f2`;
                        MON_str="between $FR_NUM_MONTH and $TO_NUM_MONTH a month"
                    elif [[ $MONTH =~ ^[0-9]{1,2}-[0-9]{1,2}\/[0-9]{1,2}$ && ! -z $MONTH ]]; then
                        NUM_MONTH=`echo "$MONTH" |cut -d"/" -f2`;
                        MONTH_RANGE=`echo "$MONTH" |cut -d"/" -f1`;
                        FR_NUM_MONTH=`echo "$MONTH_RANGE" |cut -d"-" -f1`;
                        TO_NUM_MONTH=`echo "$MONTH_RANGE" |cut -d"-" -f2`;
                        MON_str="between $FR_NUM_MONTH and $TO_NUM_MONTH a
                month, every $NUM_MONTH a month"
                    fi;
                else
                    MON_str=""
                fi;

                #week day
                if [[ ! $WEEK_DAY =~ ^\*$ && ! -z $WEEK_DAY ]]; then
                    if [[ $WEEK_DAY =~ ^\*\/[0-9]{1,2}$ && ! -z $WEEK_DAY ]]; then
                        NUM_WEEK=`echo "$WEEK_DAY" |cut -d"/" -f2`
                        WEK_str="every $NUM_WEEK weeks"
                    elif [[ $WEEK_DAY =~ ^[0-9]{1,2}$ && ! -z $WEEK_DAY ]]; then
                        WEK_str="every $WEEK_DAY_NAME"
                    elif [[ $WEEK_DAY =~ ^[0-9]{1,2}-[0-9]{1,2}$ && ! -z $WEEK_DAY ]]; then
                        FR_NUM_WEEK_DAY=`echo "$WEEK_DAY" |cut -d"-" -f1`;
                        TO_NUM_WEEK_DAY=`echo "$WEEK_DAY" |cut -d"-" -f2`;
                        WEK_str="between $FR_NUM_WEEK_DAY and $TO_NUM_WEEK_DAY
                each week"
                    elif [[ $WEEK_DAY =~ ^[0-9]{1,2}-[0-9]{1,2}\/[0-9]{1,2}$ && ! -z $WEEK_DAY ]]; then
                        NUM_WEEK_DAY=`echo "$WEEK_DAY" |cut -d"/" -f2`;
                        WEEK_DAY_RANGE=`echo "$WEEK_DAY" |cut -d"/" -f1`;
                        FR_NUM_WEEK_DAY=`echo "$WEEK_DAY_RANGE" |cut -d"-" -f1`;
                        TO_NUM_WEEK_DAY=`echo "$WEEK_DAY_RANGE" |cut -d"-" -f2`;
                        MON_str="between $FR_NUM_WEEK_DAY and $TO_NUM_WEEK_DAY
                days of the week, every $NUM_WEEK_DAY days"
                    fi;
                else
                    WEK_str=""
                fi;

            #generate string for end user
            if [[ $COMBINED_DATE == 1 ]]; then
                if [[ $MIN_str =~ ^[0-9]{1}$ ]]; then
                    MIN_str="0$MIN_str"
                fi;
                TIME_str="$HR_str:$MIN_str, "
            else
                if [[ ! -z $HR_str ]]; then
                    TIME_str="$HR_str, "
                else
                    TIME_str="$TIME_str$MIN_str, "
                fi;
            fi;

            if [[ ! -z $WEK_str || ! -z $MON_str || ! -z $MON_D_str ]]; then
                if [[ ! -z $WEK_str ]]; then
                    DATE_str="$WEK_str, "
                fi;
                if [[ ! -z $MON_str ]]; then
                    DATE_str="$DATE_str$MON_str, "
                fi;
                if [[ ! -z $MON_D_str ]]; then
                    DATE_str="$DATE_str$MON_D_str, "
                fi;
            else
                DATE_str="daily"
            fi;

            if [[ $DATE_str =~ ^daily$ ]]; then
                echo "$ECHO_str $DATE_str $TIME_str" | sed 's/.\{2\}$//'
            else
                echo "$ECHO_str $TIME_str $DATE_str" | sed 's/.\{2\}$//'
            fi;

            echo ""
        fi;
done;
exit 0;
