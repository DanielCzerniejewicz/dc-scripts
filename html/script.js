function updateInventoryUI(items) {
    const inventoryList = document.getElementById('inventory-list');
    inventoryList.innerHTML = '';

    (items || []).forEach(item => {
        const div = document.createElement('div');
        div.className = 'inventory-item';

        if (item.type === 'weapon') {
            div.innerText = `${item.label}`;
        } else {
            div.innerText = `${item.label} x${item.amount}`;
        }

        div.addEventListener('click', () => {
            if (item.type === 'weapon') {
                fetch(`https://${GetParentResourceName()}/equipWeapon`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ item: item.id })
                });
            } else {
                fetch(`https://${GetParentResourceName()}/useItem`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ item: item.id })
                });
            }
        });

        inventoryList.appendChild(div);
    });
}

function showInventoryUI(items) {
    document.getElementById('inventory-overlay').style.display = 'block';
    document.getElementById('inventory-ui').style.display = 'block';
    updateInventoryUI(items);
}

function hideInventoryUI() {
    document.getElementById('inventory-overlay').style.display = 'none';
    document.getElementById('inventory-ui').style.display = 'none';
}

window.addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.type === 'open') {
        showInventoryUI(data.inventory || []);
    } else if (data.type === 'close') {
        hideInventoryUI();
    }
});

window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});

// document.getElementById('close-inventory').addEventListener('click', () => {
//     fetch(`https://${GetParentResourceName()}/close`, {
//         method: 'POST',
//         headers: { 'Content-Type': 'application/json' },
//         body: JSON.stringify({})
//     });
// });
