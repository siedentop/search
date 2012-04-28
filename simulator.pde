Search search;

float LENGTH = 25.0;
float MIN_DIST = 10.0; // Distance within goal is considered reached

void setup() {
    noLoop();
    size(200, 200);
    background(0, 48, 124);
    PVector pose = new PVector(100, 100);
    search = new Search(pose);
    search.find(new PVector(200,0));
}
void draw() {
    search.draw();
}
class Search {
    PVector goal;
    Node current;
    Node[] active;
    Search(PVector startPose) {
        current = new Node(startPose, 0.0, 0.0);
        active = {};
    }
    void draw() {
        // draw current start node
        current.draw();
        // Draw Goal in Yellow
        fill(255,255,0);
        stroke(255);
        if(goal != null) {
            ellipse(goal.x, goal.y, 10, 10);
        }
        // Draw active nodes
        for(int i=0; i<active.length; i++) {
            active[i].draw();
        }
    }
    void find(PVector goal_) {
        goal = goal_;
        if(current.goalReached()) {
            return;
        } else {
            float[] angle = {0, -PI/6, PI/6};
            for (int i=0; i<angle.length; i++)
            {
                append(active, current.getChild(30.0, angle[i]));
            }
        }
    }
    class Node {
        PVector pos, end;
        Node parent; ///< will be null if Node is start node.
        Node(PVector startPose, float distance, float wheelangle) {
            pos = startPose;
            // Basic bicycle model
            float beta = distance * tan(wheelangle) / LENGTH;
            if(abs(beta) < 0.001)
            {
                float x = pos.x + distance * cos(pos.z);
                float y = pos.y + distance * sin(pos.z);
                float theta = (pos.z + wheelangle) % (2*PI);
                end = new PVector(x, y, theta);
            }
            else
            {
                float R = distance / beta;
                float cx = pos.x - sin(pos.z)*R;
                float cy = pos.y + cos(pos.z)*R;
                float x = cx + sin(pos.z+beta)*R;
                float y = cy - cos(pos.z+beta)*R;
                float theta = (pos.z+beta) % (2*PI);
                end = new PVector(x, y, theta);
            }
        }
        void draw() {
            stroke(255);
            fill(100);
            ellipse(pos.x, pos.y, 10, 10);
            line(pos.x, pos.y, end.x, end.y);
        }
        boolean goalReached() {
            return (pow(goal.x - end.x, 2) + pow(goal.y - end.y, 2) < pow(MIN_DIST, 2));
        }
        Node getChild(float distance, float wheelangle) {
            result = new Node(end, distance, wheelangle);
            result.parent = this;
            return result;
        }
    }
}
