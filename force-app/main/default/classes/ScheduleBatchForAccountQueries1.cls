global class ScheduleBatchForAccountQueries1 implements Schedulable {
    global void execute(SchedulableContext ctx) {
        BatchForAccountQueries1 bc = new BatchForAccountQueries1();
        database.executebatch(bc,100);
    }
}