@isTest
public class SchedulingUtilTest {
    
    private static Time t = DateTime.now().time();
    
    @isTest static void testGetCronMinFromNow() {
        Integer offset = 30; 
        String minFromNow = t.addMinutes(offset).minute().format(); 
        system.assert( SchedulingUtil.getCronMinFromNow(offset).contains(minFromNow) );
    }
    
    @isTest static void testGetCronSecFromNow() {
        Integer offset = 120; 
        String minFromNow = t.addSeconds(offset).minute().format(); 
        String cron = SchedulingUtil.getCronSecFromNow(offset); 
        system.assert( cron.contains(minFromNow) );
    }
    
    @isTest static void testScheduleMinFromNow() {
        String jobName = 'mockSched'; 
        SchedulingUtil.scheduleMinFromNow(jobName, new MockSched(), 30); 
        List<CronTrigger> jobIds = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName]; 
        system.assert(jobIds.size() == 1);
        // test future removal (code coverage only for @future method) 
        SchedulingUtil.futureAbortJob(jobIds[0].id); 
    }
    
    public class MockSched implements Schedulable {
        public void execute(System.SchedulableContext sc) {
            
        }
    }
    
}