global class ScheduleBatchForAccountQueries3 implements Schedulable {
    global void execute(SchedulableContext ctx) {
        BatchForAccountQueries3 bc = new BatchForAccountQueries3();
        database.executebatch(bc,100);
    }
}