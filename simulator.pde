
Robot robot;

float LENGTH = 25.0;
float WIDTH = 10.0;
float distance = 60.0;

PVector goal = new PVector(10.0, 0.0);

void setup()
{
  size(200,200);
  background(0,48,160);
  noLoop();
  robot = new Robot(100, 100, 0.0);
}

void draw()
{
	robot.run();
}

void drawArc(float R, float arclength)
{
	noFill();
	if (R==0)
	{
		line(0,0,0, arclength);
	}
	else if (R>0)
	{
		arc(-R, 0, 2*R, 2*R, 0, arclength/R);
	}
	else
	{
		R = -R;
		arc(R, 0, 2*R, 2*R, PI-arclength/R, PI);
	}
}

class Robot {
	float theta;
	PVector pos;
	Robot(float px, float py, float ptheta)
	{
		pos = new PVector(px, py);
		theta = ptheta;
		println("Robot Constructor");
	}
	
	void run()
	{
		theta += PI/3.0;
		findGoal();
		render();
	}
	
	void render()
	{
		fill(100);
		stroke(255);
		
		translate(pos.x, pos.y);
		rotate(theta);
		rect(-WIDTH/2, 0, WIDTH, LENGTH); // draw in middle of front axle
		float arclength = 60;
		float[] radii = {0, -1, 1, -2, 2};
		for (int i=0; i<radii.length; i++)
		{
			drawArc(radii[i] * 30, arclength);
		}
	}
	
	Node findGoal()
	{
		Node startNode = new Node(pos, distance, 0);
		Node currentNode = startNode;
		Node[] activeNodes = {};
		if (currentNode.goalReached(distance))
		{
			return currentNode;
		}
		else
		{
			float[] angle = {0, -PI/6, PI/6};
			for (int i=0; i<angle.length; i++)
			{
				append(activeNodes, currentNode.getChildNode(angle[i]));
			}
// 			Arrays.sort(activeNodes); 
			sort(activeNodes);
		}
                return currentNode;
	}
}

// A path segment
class Node implements Comparable<Node>
{
	PVector endPoint, pos;
	Node(PVector startPoint, float distance, float alpha)
	{
		println("Node created: " + startPoint + " Alpha" + alpha);
		pos = startPoint; // pose is x, y, theta.
		// Basic bicycle model
		float beta = distance * tan(alpha) / LENGTH;
		if(abs(beta) < 0.001)
		{
			float x = pos.x + distance * cos(pos.z);
			float y = pos.y + distance * sin(pos.z);
			float theta = (pos.z + alpha) % (2*PI);
			endPoint = new PVector(x, y, theta);
		}
		else
		{
			float cx = pos.x - sin(pos.z)*R;
			float cy = pos.y + cos(pos.z)*R;
			float x = cx + sin(pos.z+beta)*R;
			float y = cy - cos(pos.z+beta)*R;
			float theta = (pos.z+beta) % (2*PI);
			endPoint = new PVector(x, y, theta);
		}
	}
	
	Node getChildNode(float alpha)
	{
                Node result;
                result = new Node(endPoint, distance, alpha);
		return result;
	}
	
	// Goal is reached
	boolean goalReached(float distance)
	{
		if (pow(goal.x - endPoint.x, 2) + pow(goal.y - endPoint.y, 2) < pow(distance, 2))
			return true;
		else
			return false;
	}
	
	float cost()
	{
		return 42.5;
	}
	
	/* Overload compareTo method */
	public int compareTo(Node other)
	{
		if( cost() > other.cost())
			return 1;
		else if(cost() < other.cost())
			return -1;
		else
			return 0;
	}
}
