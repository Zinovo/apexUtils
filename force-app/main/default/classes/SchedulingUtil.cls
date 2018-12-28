/**
 * @author Kevin Rice
 * @date 2017.11.14
 * @group Utilities
 * @description Provides methods for common utilities around schedulable Apex. All methods are static. 
 **/ 

public class SchedulingUtil {

    public final static Integer MIN_OFFSET = 1; 
    
    
    /**
     * @description Allows caller to retrieve a valid CRON string x minutes in the future, for a job that will run once and only once. 
     * @param *minFromNow* Integer. Minutes in the future. If less than the allowable offset, the minimum will be used.
     * @return String. Properly formatted CRON string.
     **/
    public static String getCronMinFromNow(Integer minFromNow) {
        if (minFromNow < MIN_OFFSET) {
            minFromNow = MIN_OFFSET; 
        }
        DateTime now = DateTime.now();
        return getCronFromDateTime(now.addMinutes(minFromNow));  
    }
    
    /**
     * @description Allows caller to retrieve a valid CRON string x seconds in the future, for a job that will run once and only once. 
     * @param *minFromNow* Integer. Seconds in the future. If less than the allowable offset, the minimum will be used.
     * @return String. Properly formatted CRON string.
     **/
    public static String getCronSecFromNow(Integer secondsFromNow) {
        if ( (secondsFromNow / 60) < MIN_OFFSET ) {
            secondsFromNow = 60; 
        }
        DateTime now = DateTime.now();
        return getCronFromDateTime(now.addSeconds(secondsFromNow)); 
    }
    
    /**
     * @description Provided a future DateTime, returns a valid CRON string for it for a job that will run once and only once. 
     * @param *dt* DateTime. A DateTime in the future. 
     * @return String. Properly formatted CRON string.
     **/
    public static String getCronFromDateTime(DateTime dt) {
        return '0 ' + dt.format('m H d M ? yyyy'); 
    }
    
    /** 
     * @description Returns a CRON string expression equal to the next future occurence of the provided runTime argument. 
     * @param *runTime* Time.
     * @return String. Properly formatted CRON String that, when used to schedule schedulable Apex, will result in a job running once and only once.  
     **/
    public static String getCronFromTime(Time runTime) {
        Integer hourOffset = (runTime.hour() - DateTime.now().hour())*60; 
        Integer minuteOffset = runTime.minute() - DateTime.now().minute(); 
        Integer totalOffset = hourOffset + minuteOffset; 
        If (totalOffset < 0) {
            totalOffset = 1440 + totalOffset; 
        }
        String cronStr = '0 ' + DateTime.now().addMinutes(totalOffset).format('m H d M ? yyyy'); 
        return cronStr;
    }
    
    /**
     * @description Allows caller to schedule a job to run once, x days from now.
     * @param *jobName* String. Name of the job that will be scheduled.
     * @param *schedulable* Schedulable. The schedulable class to run. 
     * @param *daysFromNow* Integer. Number of days from now for the class to run.
     **/
    public static void scheduleDaysFromNow(String jobName, Schedulable schedulable, Integer daysFromNow) {
        // convert to minutes
        Integer minFromNow = daysFromNow * 24 * 60; 
        scheduleMinFromNow(jobName, schedulable, minFromNow, true); 
    }
    
    /**
     * @description Allows caller to schedule a job to run once, x minutes from now. 
     * @param *jobName* String. Name of the job that will be scheduled.
     * @param *schedulable* Schedulable. The schedulable class to run. 
     * @param *minFromNow* Integer. Number of minutes from now for the class to run.
     **/
    public static void scheduleMinFromNow(String jobName, Schedulable schedulable, Integer minFromNow) {
        scheduleMinFromNow(jobName, schedulable, minFromNow, true); 
    }
    
    /**
     * @description Allows caller to schedule a schedulable Apex class x minutes from now. If x is less than the allowable offset, the minimum will be used.
     * @param *jobName* String. Name for the scheduled job. 
     * @param *schedulable* Schedulable. Apex class implementing the Schedulable interface.
     * @param *minFromNow* Integer. Minutes from the current time that the job will run. 
     * @param *doRemovePrior* Boolean. When set to true, will remove any existing scheduled jobs of the same name that have previously run. Default is true. 
     **/
    public static void scheduleMinFromNow(String jobName, Schedulable schedulable, Integer minFromNow, Boolean doRemovePrior) {
        // first, delete any old jobs, if required
        try {
            if (doRemovePrior) {
                for (CronTrigger ct : [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :jobName]) {
                    System.abortJob(ct.id); 
                }
            }
            System.schedule(jobName, getCronMinFromNow(minFromNow), schedulable); 
        } catch (Exception e) {
            throw e; 
        }
    }
    
    /**
     * @description Allows caller to cancel a currently running schedulable job. Job abort will occur in a future context
     * @param *schedulableContext* System.SchedulableContext. The context of the schedulable job to be removed after completion.
     **/
    public static void removeAfterCompletion(System.SchedulableContext schedulableContext) {
        futureAbortJob( schedulableContext.getTriggerId() ); 
    }
    
    /**
     * @description Allows caller to abort a scheduled job in a future context, by providing its trigger id
     * @param *triggerId* Id. The Id of the job to abort. May be obtained via Schedulable.getTrigger() method.
     **/
    @future
    public static void futureAbortJob(Id triggerId) {
        System.abortJob(triggerId); 
    }
    
}