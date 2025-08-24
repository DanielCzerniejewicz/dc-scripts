window.addEventListener('message', function(event) {
    if (event.data.action === "showPing") {
        const container = document.getElementById('ping-container');
        const ping = document.createElement('div');
        ping.className = 'ping';

        const icon = document.createElement('span');
        icon.className = 'icon';
        icon.innerText = '✔'; 

        const text = document.createElement('span');
        text.innerText = event.data.text;

        ping.appendChild(icon);
        ping.appendChild(text);
        container.appendChild(ping);

        setTimeout(() => {
            ping.remove();
        }, 3000); 
    }
});
