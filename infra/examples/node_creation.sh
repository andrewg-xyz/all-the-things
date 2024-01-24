# Create a new node with id 123 and ip 23.0.0.24
../node/create_node.sh -n 123 -i 24

# Create many nodes
for i in {1..10}; do
    ../node/create_node.sh -n $i -i $i
done