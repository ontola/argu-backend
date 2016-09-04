### Vertical List

    const items = ['1', '2', '3', '4'];
    const renderItem = (id) => <Box>{id}</Box>;
    <List items={items} renderItem={renderItem} />

### Horizontal List

    const items = ['1', '2', '3', '4'];
    const renderItem = (id) => <Box>{id}</Box>;
    <List items={items} renderItem={renderItem} align="horizontal" />
