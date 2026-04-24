public class QuizLeaderboard {

    public static void runTask() {

        String regNo = 'YOUR_REG_NO'; // ⚠️ replace with your reg no

        Set<String> seen = new Set<String>();
        Map<String, Integer> scores = new Map<String, Integer>();

        Http http = new Http();

        for (Integer i = 0; i < 10; i++) {

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://devapigw.vidalhealthtpa.com/srm-quiz-task/quiz/messages?regNo=' + regNo + '&poll=' + i);
            req.setMethod('GET');

            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {

                Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> events = (List<Object>) data.get('events');

                for (Object e : events) {

                    Map<String, Object> event = (Map<String, Object>) e;

                    String roundId = (String) event.get('roundId');
                    String participant = (String) event.get('participant');
                    Integer score = (Integer) event.get('score');

                    String key = roundId + '_' + participant;

                    if (!seen.contains(key)) {
                        seen.add(key);

                        if (!scores.containsKey(participant)) {
                            scores.put(participant, score);
                        } else {
                            scores.put(participant, scores.get(participant) + score);
                        }
                    }
                }
            }
        }

        // Sort leaderboard
        List<String> names = new List<String>(scores.keySet());
        names.sort(new ScoreComparator(scores));

        List<Map<String, Object>> leaderboard = new List<Map<String, Object>>();

        for (String name : names) {
            Map<String, Object> obj = new Map<String, Object>();
            obj.put('participant', name);
            obj.put('totalScore', scores.get(name));
            leaderboard.add(obj);
        }

        // Prepare final JSON
        Map<String, Object> finalBody = new Map<String, Object>();
        finalBody.put('regNo', regNo);
        finalBody.put('leaderboard', leaderboard);

        String jsonBody = JSON.serialize(finalBody);

        // POST request
        HttpRequest postReq = new HttpRequest();
        postReq.setEndpoint('https://devapigw.vidalhealthtpa.com/srm-quiz-task/quiz/submit');
        postReq.setMethod('POST');
        postReq.setHeader('Content-Type', 'application/json');
        postReq.setBody(jsonBody);

        HttpResponse postRes = http.send(postReq);

        System.debug(postRes.getBody());
    }

    // Sorting class
    public class ScoreComparator implements Comparator<String> {
        Map<String, Integer> scores;

        public ScoreComparator(Map<String, Integer> scores) {
            this.scores = scores;
        }

        public Integer compare(String a, String b) {
            return scores.get(b) - scores.get(a);
        }
    }
}
