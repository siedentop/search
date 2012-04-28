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
    println("Success!");
}

/// Return distance squared between two PVectors but only in 2D. z value is discarded
float distance_sq(PVector a, PVector b) {
    return (a.x - b.x)*(a.x-b.x) + (a.y - b.y)*(a.y - b.y);
}

class Search {
    PVector goal;
    Node current;
    ArrayList<Node> active;
    Search(PVector startPose) {
        current = new Node(startPose, 0.0, 0.0);
        active = new ArrayList<Node>;
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
        for(int i=0; i<active.size(); i++) {
            active.get(i).draw();
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
                active.add(current.getChild(30.0, angle[i]));
            }
            active = quicksort(active);
        }
    }
    class Node implements Comparable<Node> {
        PVector pos, end;
        Node parent; ///< will be null if Node is start node.
        float gcost;
        Node(PVector startPose, float distance, float wheelangle) {
            pos = startPose;
            if (parent == null) {
                gcost = 0.0;
            } else {
                gcost += parent.gcost;
            }
            gcost += distance; // add path length
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
            result = (distance_sq(goal, end) < pow(MIN_DIST, 2));
            if (result)
                println("Goal Reached!");
            return result;
        }
        Node getChild(float distance, float wheelangle) {
            result = new Node(end, distance, wheelangle);
            result.parent = this;
            return result;
        }
        float fcost() {
            float h = sqrt(distance_sq(end, goal));
            return h + gcost;
        }
    }
}

int compare(Node a, Node b) {
    if( a.fcost() > b.fcost())
        return 1;
    else if(a.fcost() < b.fcost())
        return -1;
    else
        return 0;
}

ArrayList<Node> quicksort(ArrayList<Node> array) {
    if (array.size() <= 1) return array;
    int pos = (int)(array.size()/2.0);
    Node pivot = array.get(pos);

    ArrayList<Node> left = new ArrayList<Node>;
    ArrayList<Node> right = new ArrayList<Node>;

    for(Node node: array) {
        if(node == pivot) continue;
        if (compare(node, pivot) <= 0) {
            left.add(node);
        } else {
            right.add(node);
        }
    }
    array.clear();

    ArrayList<Node> result = new ArrayList<Node>;
    result.addAll(quicksort(left));
    result.add(pivot);
    result.addAll(quicksort(right));
    return result;
}
