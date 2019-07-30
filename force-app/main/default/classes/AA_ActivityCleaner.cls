public class AA_ActivityCleaner{
	
	public static void cleanActivities(){
		list<ID> exclusions = new list<ID>();
		//Partner First Task
		exclusions.add('0121B000001CGNN');
		//Partner First Event
		exclusions.add('01213000001WHKc');
		
		list<Event> events = new list <Event>();
		list<Task> tasks = new list<Task>();
		
		events = [SELECT ID FROM Event WHERE RecordTypeID NOT IN: exclusions AND ActivityDate < LAST_N_MONTHS:24 LIMIT 10000];
		tasks = [SELECT ID FROM Task WHERE RecordTypeID NOT IN: exclusions AND ActivityDate < LAST_N_MONTHS:24 LIMIT 10000];
		
		system.debug('Events: ' + events + ' size: ' + events.size());
		system.debug('Tasks: ' + tasks + ' size: ' + tasks.size());
		delete events;
		delete tasks;
		}
    
}