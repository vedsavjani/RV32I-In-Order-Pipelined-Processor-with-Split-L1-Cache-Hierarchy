#define V 9
#define INF 2147483647

int graph[V][V];
int dist[V];
int visited[V];
int output[V];

void init_graph() {
    int i, j;
    for (i = 0; i < V; i++)
        for (j = 0; j < V; j++)
            graph[i][j] = 0;

    graph[0][1] = 4;  graph[1][0] = 4;
    graph[0][7] = 8;  graph[7][0] = 8;
    graph[1][2] = 8;  graph[2][1] = 8;
    graph[1][7] = 11; graph[7][1] = 11;
    graph[2][3] = 7;  graph[3][2] = 7;
    graph[2][5] = 4;  graph[5][2] = 4;
    graph[2][8] = 2;  graph[8][2] = 2;
    graph[3][4] = 9;  graph[4][3] = 9;
    graph[3][5] = 14; graph[5][3] = 14;
    graph[4][5] = 10; graph[5][4] = 10;
    graph[5][6] = 2;  graph[6][5] = 2;
    graph[6][7] = 1;  graph[7][6] = 1;
    graph[6][8] = 6;  graph[8][6] = 6;
    graph[7][8] = 7;  graph[8][7] = 7;
}

int min_distance() {
    int min = INF, min_index = 0;
    int v;
    for (v = 0; v < V; v++)
        if (!visited[v] && dist[v] <= min) {
            min = dist[v];
            min_index = v;
        }
    return min_index;
}

void dijkstra(int src) {
    int i, count, u, v;
    for (i = 0; i < V; i++) {
        dist[i] = INF;
        visited[i] = 0;
    }
    dist[src] = 0;
    for (count = 0; count < V - 1; count++) {
        u = min_distance();
        visited[u] = 1;
        for (v = 0; v < V; v++) {
            if (!visited[v] && graph[u][v] &&
                dist[u] != INF &&
                dist[u] + graph[u][v] < dist[v])
                dist[v] = dist[u] + graph[u][v];
        }
    }
}

int main() {
    int i;
    volatile int* out = (volatile int*)0x2100;
    init_graph();
    dijkstra(0);
    for (i = 0; i < V; i++)
        out[i] = dist[i];
    return 0;
}