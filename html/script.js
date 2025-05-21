
let cardNumbers = []
let selectedNumbers = []
let chosenNumers = []

window.addEventListener('message', function(event) {
    const data = event.data
    if (data.action === 'openBingoCard') {
        cardNumbers = data.numbers
        selectedNumbers = data.selected || []
        renderCard()
        document.body.style.display = 'flex'
    } else if (data.action === 'newNumber') {
            const display = document.getElementById('latestNumberDisplay')
            display.textContent = "Latest Selected Number: " + data.number
            chosenNumers.push(data.number)
    } else if (data.action === 'resetGame') {
            const display = document.getElementById('latestNumberDisplay')
            display.textContent = "Game has been Reset"
            chosenNumers = []
    }
})

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeCard()
    }
})

function renderCard() {
    const grid = document.getElementById('bingoGrid')
    grid.innerHTML = ''
    cardNumbers.forEach(num => {
        const div = document.createElement('div')
        div.className = 'cell'
        div.textContent = num
        if (selectedNumbers.includes(num)) {
            div.classList.add('selected')
        }
        div.onclick = () => {
            if (!selectedNumbers.includes(num)) {
                selectedNumbers.push(num)
                div.classList.add('selected')
                fetchNUI('selectNumber', { number: num })
            }
        }
        grid.appendChild(div)
    })
}

function checkBingo() {
    fetchNUI('checkBingo')
}

function resetCard() {
    selectedNumbers = []
    renderCard() // This re-renders and ensures the grid resets
    fetchNUI('resetCard')
}

function closeCard() {
    document.body.style.display = 'none'
    fetchNUI('closeCard')
}

function fetchNUI(action, data = {}) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    })
}


async function uploadElementAsImageToDiscordWebhook() {
    // Get the element
    const elementId = 'bingoGrid'; // ID of the element to capture
    const webhookUrl = ''; // Replace with your Discord webhook URL
    const element = document.getElementById(elementId);

    const playerName = await fetch(`https://${GetParentResourceName()}/getPlayerName`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({})
    }).then(response => response.text()).catch(error => {
        console.error('Error fetching player name:', error);
        return 'Unknown Player';
    });

    if (!element) {
        console.error('Element not found');
        return;
    }

    // Load html2canvas dynamically
    const script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js';
    document.head.appendChild(script);

    script.onload = () => {
        // Capture the element as a canvas
        html2canvas(element, {
            useCORS: true,
            logging: false
        }).then(canvas => {
            // Convert canvas to a blob
            canvas.toBlob(blob => {
                // Create a form data object for the file
                const formData = new FormData();
                formData.append('file', blob, 'element.png');
                formData.append('payload_json', JSON.stringify({
                    //content: 'Player Name: ' + playerName,
                    embeds: [{
                        title: 'Bingo Card for ' + playerName,
                        description: 'Here is the card!',
                        color: 0x00FF00,
                        image: {
                            url: 'attachment://element.png'
                        }
                    }, {
                        title: 'Drawn Numbers',
                        description: 'Here are the drawn numbers: ' + chosenNumers.join(', '),
                        color: 0x00FF00,
                    }]
                }));

                // Send to Discord webhook
                fetch(webhookUrl, {
                    method: 'POST',
                    body: formData
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Failed to send to Discord webhook');
                    }
                    console.log('Successfully uploaded image to Discord');
                })
                .catch(error => {
                    console.error('Error uploading to Discord:', error);
                });
            }, 'image/png');
        }).catch(error => {
            console.error('Error capturing element:', error);
        });
    };

    script.onerror = () => {
        console.error('Failed to load html2canvas library');
    };
}

// Example usage:
// uploadElementAsImageToDiscordWebhook('bingoGrid', 'YOUR_DISCORD_WEBHOOK_URL');